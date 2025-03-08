package model

type MqMessage struct {
	MessageId string
	Body      string
}

type MqDetails struct {
	Message *MqMessage
}

type MqMessageData struct {
	Details *MqDetails
}

type MqRequest struct {
	Messages []MqMessageData
}
