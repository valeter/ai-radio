module github.com/valeter/ai-radio/speech-generator/server

go 1.22.2

replace github.com/valeter/ai-radio/speech-generator/model => ../model

require (
	github.com/aws/aws-sdk-go v1.55.6
	github.com/valeter/ai-radio/speech-generator/model v0.0.0-00010101000000-000000000000
	google.golang.org/genproto/googleapis/api v0.0.0-20241202173237-19429a94021a
	google.golang.org/grpc v1.70.0
	google.golang.org/protobuf v1.36.5
)

require (
	github.com/jmespath/go-jmespath v0.4.0 // indirect
	golang.org/x/net v0.32.0 // indirect
	golang.org/x/sys v0.28.0 // indirect
	golang.org/x/text v0.21.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20241202173237-19429a94021a // indirect
)
