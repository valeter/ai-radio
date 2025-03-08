module github.com/valeter/ai-radio/speech-generator/cli-client

go 1.21.9

replace github.com/valeter/ai-radio/apps/go/common/model => ./../../common/model

require (
	github.com/aws/aws-sdk-go v1.55.6
	github.com/valeter/ai-radio/apps/go/speech-generator v0.0.0-00010101000000-000000000000
	google.golang.org/protobuf v1.36.5
)

require (
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/jmespath/go-jmespath v0.4.0 // indirect
)

replace github.com/valeter/ai-radio/apps/go/speech-generator => ../
