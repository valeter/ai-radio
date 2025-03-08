package main

import (
	"encoding/hex"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	pb "github.com/valeter/ai-radio/apps/go/speech-generator/generated/voicegen"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
	"os"
)

// env variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY should be set
func main() {
	if len(os.Args) != 3 {
		fmt.Println("usage: cli-client [sqs url] [json message]")
		fmt.Println("example: ./cli-client $SQS_URL '{\"text\":\"привет\",\"result_file_type\":\"MP3\", \"speed\":12, \"tts_voice\":\"ANTON\", \"tts_role\": \"NEUTRAL\", \"s3_bucket\":\"ai-radio-music\", \"s3_folder\":\"test/1\", \"s3_unique_key\": \"hi\"}'")
		return
	}

	sess, err := session.NewSession(&aws.Config{
		Endpoint: aws.String("https://message-queue.api.cloud.yandex.net/"),
		Region:   aws.String("ru-central1"),
	})
	if err != nil {
		fmt.Println("session create error:", err)
		return
	}

	svc := sqs.New(sess)

	str := os.Args[2]
	msgO := pb.VoiceGenerationRequest{}
	err = protojson.Unmarshal([]byte(str), &msgO)
	if err != nil {
		fmt.Println("bad json input:", err)
		return
	}

	src, err := proto.Marshal(&msgO)
	if err != nil {
		fmt.Println("can't marshal to proto:", err)
		return
	}
	dst := make([]byte, hex.EncodedLen(len(src)))
	hex.Encode(dst, src)
	msg := string(dst)
	fmt.Printf("sending message: %v\n", msg)

	sendParams := &sqs.SendMessageInput{
		MessageBody:    aws.String(msg),
		QueueUrl:       aws.String(os.Args[1]),
		MessageGroupId: aws.String("speech-generator"),
	}

	// Отправляем сообщение
	sendResp, err := svc.SendMessage(sendParams)
	if err != nil {
		fmt.Println("message sending error:", err)
		return
	}

	// Выводим ID отправленного сообщения
	fmt.Println("message sucessfully sent, message_id:", *sendResp.MessageId)
}
