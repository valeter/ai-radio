package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/valeter/ai-radio/apps/go/common/model"
	"google.golang.org/protobuf/proto"
	"io"
	"os"
	"strings"
	"unicode/utf8"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"

	pb "github.com/valeter/ai-radio/apps/go/speech-generator/generated/voicegen"
	pbyc "github.com/valeter/ai-radio/apps/go/speech-generator/generated/yandex/cloud/ai/tts/v3"
)

const (
	s3Region      = "ru-central1"
	maxMsgTextLen = 2000
)

//goland:noinspection GoUnusedParameter
func HandleRequest(ctx context.Context, reqbody []byte) (string, error) {
	req := model.MqRequest{}
	err := json.Unmarshal(reqbody, &req)
	if err != nil {
		fmt.Printf("Ошибка при парсинге сообщения %v: %s\n", string(reqbody), err)
		return "", err
	}

	fmt.Printf("Получено %v сообщений\n", len(req.Messages))

	for _, message := range req.Messages {
		err = processMessage(message.Details.Message)
		if err != nil {
			fmt.Printf("Ошибка при обработке сообщения %v: %s\n", message.Details.Message.MessageId, err)
			return fmt.Sprintf("Сообщение не обработано %v\n", message.Details.Message.MessageId), err
		}

		fmt.Printf("Сообщение успешно обработано %v\n", message.Details.Message.MessageId)
	}

	fmt.Printf("Сообщения обработаны\n")
	return "Сообщения обработаны", nil
}

func processMessage(message *model.MqMessage) error {
	fmt.Printf("Тело сообщения: %s\n", message.Body)

	msg := pb.VoiceGenerationRequest{}
	bodyBytes, err := hex.DecodeString(message.Body)
	if err != nil {
		fmt.Printf("Ошибка hex формата сообщения %s. Сообщение не будет обработано вторично\n", err)
		return nil
	}
	err = proto.Unmarshal(bodyBytes, &msg)
	if err != nil {
		fmt.Printf("Ошибка формата сообщения %s. Сообщение не будет обработано вторично\n", err)
		return nil
	}

	var audioType pbyc.ContainerAudio_ContainerAudioType
	switch msg.ResultFileType {
	case pb.FileType_MP3:
		audioType = pbyc.ContainerAudio_MP3
	default:
		fmt.Printf("Неподдерживаемый формат файла %v. Сообщение не будет обработано вторично\n", msg.ResultFileType)
		return nil
	}

	if utf8.RuneCountInString(msg.Text) > maxMsgTextLen {
		fmt.Printf("Слишком длинный текст %v. Сообщение не будет обработано вторично\n", utf8.RuneCountInString(msg.Text))
		return nil
	}

	voice, err := voiceToString(msg.TtsVoice)
	if err != nil {
		fmt.Printf("Неподдерживаемый голос %v. Сообщение не будет обработано вторично\n", msg.TtsVoice)
		return nil
	}
	role, err := roleToString(msg.TtsRole)
	if err != nil {
		fmt.Printf("Неподдерживаемая роль %v. Сообщение не будет обработано вторично\n", msg.TtsRole)
		return nil
	}

	sess := session.Must(session.NewSession(&aws.Config{
		Endpoint: aws.String("https://storage.yandexcloud.net/"),
		Region:   aws.String(s3Region),
	}))
	s3Client := s3.New(sess)
	listParams := &s3.ListObjectsV2Input{
		Bucket: aws.String(msg.S3Bucket),
		Prefix: aws.String(msg.S3Folder),
	}
	_, err = s3Client.ListObjectsV2(listParams)
	if err != nil {
		fmt.Printf("Ошибка при подключении к object storage\n")
		return err
	}

	conn, err := grpc.NewClient("tts.api.cloud.yandex.net:443",
		grpc.WithTransportCredentials(credentials.NewClientTLSFromCert(nil, "")))
	if err != nil {
		fmt.Printf("Ошибка при подключении к tts\n")
		return err
	}
	defer func(conn *grpc.ClientConn) {
		err := conn.Close()
		if err != nil {
			fmt.Printf("Ошибка при закрытии подключения к tts %s\n", err)
		}
	}(conn)
	client := pbyc.NewSynthesizerClient(conn)
	ttsCtx := metadata.NewOutgoingContext(context.Background(),
		metadata.Pairs(
			"Authorization", "Api-Key "+os.Getenv("TTS_IAM_API_KEY"),
			"x-folder-id", os.Getenv("TTS_SA_FOLDER_ID"),
		))
	
	response, err := client.UtteranceSynthesis(ttsCtx, &pbyc.UtteranceSynthesisRequest{
		Utterance: &pbyc.UtteranceSynthesisRequest_Text{Text: msg.Text},
		Hints: []*pbyc.Hints{
			{
				Hint: &pbyc.Hints_Voice{Voice: voice},
			},
			{
				Hint: &pbyc.Hints_Speed{Speed: float64(msg.Speed) / 10.0},
			},
			{
				Hint: &pbyc.Hints_Role{Role: role},
			},
		},
		OutputAudioSpec: &pbyc.AudioFormatOptions{
			AudioFormat: &pbyc.AudioFormatOptions_ContainerAudio{
				ContainerAudio: &pbyc.ContainerAudio{ContainerAudioType: audioType},
			},
		},
		LoudnessNormalizationType: pbyc.UtteranceSynthesisRequest_LUFS,
		UnsafeMode:                true,
	})
	if err != nil {
		fmt.Printf("Ошибка при синтезе tts\n")
		return err
	}

	nextFileNumber := 1
	var prefix string
	if strings.HasSuffix(msg.S3Folder, "/") {
		prefix = msg.S3Folder + msg.S3UniqueKey + "_"
	} else {
		prefix = msg.S3Folder + "/" + msg.S3UniqueKey + "_"
	}
	for {
		audioData, err2 := response.Recv()
		if err2 != nil {
			if err2 == io.EOF || err2.Error() == "EOF" {
				// all messages from server processed
				break
			}
			return err2
		}
		fileName := fmt.Sprintf("%s%d.mp3", prefix, nextFileNumber)
		err2 = saveToS3(s3Client, audioData.AudioChunk.Data, msg.S3Bucket, fileName)
		if err2 != nil {
			fmt.Printf("Ошибка при сохранении в object storage: %s\n", fileName)
			return err2
		}
		fmt.Printf("Аудио успешно сохранено в object storage: %s\n", fileName)
		nextFileNumber++
	}
	return nil
}

func roleToString(role pb.Role) (string, error) {
	switch role {
	case pb.Role_NEUTRAL:
		return "neutral", nil
	case pb.Role_STRICT:
		return "strict", nil
	case pb.Role_GOOD:
		return "good", nil
	case pb.Role_EVIL:
		return "evil", nil
	case pb.Role_FRIENDLY:
		return "friendly", nil
	case pb.Role_WHISPER:
		return "whisper", nil
	default:
		return "", fmt.Errorf("неподдерживаемая роль: %d", role)
	}
}

func voiceToString(voice pb.Voice) (string, error) {
	switch voice {
	case pb.Voice_ALENA:
		return "alena", nil
	case pb.Voice_FILIPP:
		return "filipp", nil
	case pb.Voice_ERMIL:
		return "ermil", nil
	case pb.Voice_JANE:
		return "jane", nil
	case pb.Voice_MADI_RU:
		return "madi_ru", nil
	case pb.Voice_SAULE_RU:
		return "saule_ru", nil
	case pb.Voice_OMAZH:
		return "omazh", nil
	case pb.Voice_ZAHAR:
		return "zahar", nil
	case pb.Voice_DASHA:
		return "dasha", nil
	case pb.Voice_JULIA:
		return "julia", nil
	case pb.Voice_LERA:
		return "lera", nil
	case pb.Voice_MASHA:
		return "masha", nil
	case pb.Voice_MARINA:
		return "marina", nil
	case pb.Voice_ALEXANDER:
		return "alexander", nil
	case pb.Voice_KIRILL:
		return "kirill", nil
	case pb.Voice_ANTON:
		return "anton", nil
	default:
		return "", fmt.Errorf("неподдерживаемый голос: %d", voice)
	}
}

func saveToS3(s3Client *s3.S3, data []byte, bucket string, name string) error {
	_, err := s3Client.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(name),
		Body:   aws.ReadSeekCloser(strings.NewReader(string(data))),
	})
	if err != nil {
		return err
	}
	return nil
}

// env variables
//
//	AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SQS_URL
//	FOLDER_ID
//
// should be set
func main() {
	// Для локального тестирования
	req := `{
   "messages":[
      {
         "event_metadata":{
            "event_id":"cce76685-5828-4304-a83d-9564********",
            "event_type":"yandex.cloud.events.messagequeue.QueueMessage",
            "created_at":"2019-09-24T00:54:28.980441Z",
            "cloud_id":"b1gvlrnlh2sd********",
            "folder_id":"b1g88tflh2sd********"         
         },
         "details":{
            "queue_id":"yrn:yc:ymq:ru-central1:21i6v06sqmsa********:event-queue",
            "message":{
               "message_id":"cce76685-5828-4304-a83d-9564********",
               "md5_of_body":"d29343907090dff4cec4a9a0********",
               "body":"message body",
               "attributes":{
                  "SentTimestamp":"1569285804456"
               },
               "message_attributes":{
                  "messageAttributeKey":{
                     "data_type":"StringValue",
                     "string_value":"value"
                  }
               },
               "md5_of_message_attributes":"83eb2d0afefb150c1ffe69f6********"
            }
         }
      },
      {
         "event_metadata":{
            "event_id":"1f32fd25-11fc-4c08-88e7-d871********",
            "event_type":"yandex.cloud.events.messagequeue.QueueMessage",
            "created_at":"2019-09-24T00:54:28.980492Z",
            "cloud_id":"b1gvlrnlh2sd********",
            "folder_id":"b1g88tflh2sd********"
         },
         "details":{
            "queue_id":"yrn:yc:ymq:ru-central1:21i6v06sqmsa********:event-queue",
            "message":{
               "message_id":"1f32fd25-11fc-4c08-88e7-d871********",
               "md5_of_body":"d29343907090dff4cec4a9a0********",
               "body":"message body",
               "attributes":{
                  "SentTimestamp":"1569285806456"
               },
               "message_attributes":{
                  "messageAttributeKey":{
                     "data_type":"StringValue",
                     "string_value":"value"
                  }
               },
               "md5_of_message_attributes":"83eb2d0afefb150c1ffe69f6********"
            }
         }
      }
   ]
	}
	`
	_, _ = HandleRequest(context.Background(), []byte(req))
}
