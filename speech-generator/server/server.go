package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/valeter/ai-radio/speech-generator/model"
	"io"
	"log"
	"os"
	"reflect"
	"strings"
	"unicode/utf8"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/metadata"

	pb "github.com/valeter/ai-radio/speech-generator/server/generated/yandex/cloud/ai/tts/v3"
)

const (
	s3Region      = "ru-central1"
	maxMsgTextLen = 2000
)

//goland:noinspection GoUnusedParameter
func HandleRequest(ctx context.Context) (string, error) {
	sess := session.Must(session.NewSessionWithOptions(session.Options{Config: aws.Config{
		Endpoint: aws.String("https://message-queue.api.cloud.yandex.net/"),
		Region:   aws.String(s3Region),
	}}))

	svc := sqs.New(sess)
	queueURL := os.Getenv("SQS_URL")

	result, err := svc.ReceiveMessage(&sqs.ReceiveMessageInput{
		QueueUrl:            &queueURL,
		MaxNumberOfMessages: aws.Int64(1),
		VisibilityTimeout:   aws.Int64(20),
		WaitTimeSeconds:     aws.Int64(1),
	})

	if err != nil {
		log.Fatalf("Ошибка при получении сообщений: %s\n", err)
	}

	if len(result.Messages) == 0 {
		log.Printf("Сообщений нет\n")
		return "Сообщений нет", nil
	}

	log.Printf("Получено %v сообщений\n", len(result.Messages))

	for _, message := range result.Messages {
		err = processMessage(message)
		if err != nil {
			log.Printf("Ошибка при обработке сообщения %v: %s\n", message.MessageId, err)
			continue
		}

		_, err = svc.DeleteMessage(&sqs.DeleteMessageInput{
			QueueUrl:      &queueURL,
			ReceiptHandle: message.ReceiptHandle,
		})
		if err != nil {
			log.Printf("Ошибка при удалении сообщения %v: %s\n", message.MessageId, err)
			continue
		}
		log.Printf("Сообщение успешно обработано %v\n", message.MessageId)
	}

	log.Printf("Сообщения обработаны\n")
	return "Сообщения обработаны", nil
}

func processMessage(message *sqs.Message) error {
	log.Printf("Тело сообщения: %s\n", *message.Body)

	msg := model.VoiceGenerationRequest{}
	err := StrictUnmarshal([]byte(*message.Body), &msg)
	if err != nil {
		log.Printf("Ошибка формата сообщения %s. Сообщение не будет отбработано вторично\n", err)
		return nil
	}

	var audioType pb.ContainerAudio_ContainerAudioType
	switch msg.ResultFileType {
	case model.MP3:
		audioType = pb.ContainerAudio_MP3
	default:
		log.Printf("Неподдерживаемый формат файла %v. Сообщение не будет отбработано вторично\n", msg.ResultFileType)
		return nil
	}

	if utf8.RuneCountInString(msg.Text) > maxMsgTextLen {
		log.Printf("Слишком длинный текст %v. Сообщение не будет отбработано вторично\n", utf8.RuneCountInString(msg.Text))
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
		return err
	}

	conn, err := grpc.NewClient("tts.api.cloud.yandex.net:443",
		grpc.WithTransportCredentials(credentials.NewClientTLSFromCert(nil, "")))
	if err != nil {
		return err
	}
	defer func(conn *grpc.ClientConn) {
		err := conn.Close()
		if err != nil {
			log.Printf("Ошибка при закрытии подключения к tts %s\n", err)
		}
	}(conn)
	client := pb.NewSynthesizerClient(conn)
	ctx := metadata.NewOutgoingContext(context.Background(),
		metadata.Pairs(
			"Authorization", "Api-Key "+os.Getenv("TTS_IAM_API_KEY"),
			"x-folder-id", os.Getenv("FOLDER_ID"),
		))
	response, err := client.UtteranceSynthesis(ctx, &pb.UtteranceSynthesisRequest{
		Utterance: &pb.UtteranceSynthesisRequest_Text{Text: msg.Text},
		Hints: []*pb.Hints{
			{
				Hint: &pb.Hints_Voice{Voice: string(msg.TtsVoice)},
			},
			{
				Hint: &pb.Hints_Speed{Speed: float64(msg.Speed) / 10.0},
			},
			{
				Hint: &pb.Hints_Role{Role: string(msg.TtsRole)},
			},
		},
		OutputAudioSpec: &pb.AudioFormatOptions{
			AudioFormat: &pb.AudioFormatOptions_ContainerAudio{
				ContainerAudio: &pb.ContainerAudio{ContainerAudioType: audioType},
			},
		},
		LoudnessNormalizationType: pb.UtteranceSynthesisRequest_LUFS,
		UnsafeMode:                true,
	})
	if err != nil {
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
			return err2
		}
		log.Printf("Аудио успешно сохранено в S3: %s\n", fileName)
		nextFileNumber++
	}
	return nil
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

func StrictUnmarshal(data []byte, v *model.VoiceGenerationRequest) error {
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.DisallowUnknownFields()
	err := dec.Decode(v)
	if err != nil {
		return err
	}
	fields := reflect.ValueOf(v).Elem()
	for i := 0; i < fields.NumField(); i++ {
		if fields.Field(i).IsZero() {
			return errors.New(fmt.Sprintf("required field is missing: %v", fields.Type().Field(i).Name))
		}

	}
	return nil
}

// env variables
//
//	AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, QUEUE_URL
//	TTS_IAM_API_KEY, FOLDER_ID
//
// should be set
func main() {
	// Для локального тестирования
	_, _ = HandleRequest(context.Background())
}
