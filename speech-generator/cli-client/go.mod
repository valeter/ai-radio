module github.com/valeter/ai-radio/speech-generator/cli-client

go 1.22.2

replace github.com/valeter/ai-radio/speech-generator/model => ../model

require (
	github.com/aws/aws-sdk-go v1.55.6 // indirect
	github.com/jmespath/go-jmespath v0.4.0 // indirect
	github.com/valeter/ai-radio/speech-generator/model v0.0.0-00010101000000-000000000000
)
