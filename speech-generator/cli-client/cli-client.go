package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/valeter/ai-radio/speech-generator/model"
	"os"
	"reflect"
)

// env variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY should be set
func main() {
	if len(os.Args) != 3 {
		fmt.Println("usage: cli-client [sqs url] [json message]")
		fmt.Println("example: ./cli-client $SQS_URL '{\"text\":\"привет\",\"resultFileType\":\"MP3\",\"speed\":12,\"ttsVoice\":\"anton\",\"ttsRole\":\"neutral\",\"S3Bucket\":\"<my_bucket>\",\"S3Folder\":\"<my_folder>\",\"S3UniqueKey\":\"<my_key>\"}'")
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
	msgO := model.VoiceGenerationRequest{}
	err = StrictUnmarshal([]byte(str), &msgO)
	if err != nil {
		fmt.Println("bad json input:", err)
		return
	}

	msgB, err := json.Marshal(&msgO)
	if err != nil {
		fmt.Println("can't build message:", err)
		return
	}
	msg := string(msgB)
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
