rm -rf proto/generated

mkdir -p proto/generated/go

if [ ! -d "proto/googleapis" ]; then
  git clone https://github.com/googleapis/googleapis.git proto/googleapis
fi
if [ ! -d "proto/cloudapi" ]; then
  git clone https://github.com/yandex-cloud/cloudapi.git proto/cloudapi
fi

protoc --proto_path=proto/googleapis \
  --proto_path=proto/cloudapi \
  --go_out=proto/generated/go \
  --go_opt=paths=source_relative \
  --go-grpc_out=proto/generated/go \
  --go-grpc_opt=paths=source_relative \
  proto/cloudapi/yandex/cloud/ai/tts/v3/*

protoc --proto_path=proto/googleapis \
  --proto_path=proto/src \
  --go_out=proto/generated/go \
  --go_opt=paths=source_relative \
  --go-grpc_out=proto/generated/go \
  --go-grpc_opt=paths=source_relative \
  proto/src/**/*.proto

rm -rf go/speech-generator/generated
mkdir -p go/speech-generator/generated
cp -r proto/generated/go/* go/speech-generator/generated