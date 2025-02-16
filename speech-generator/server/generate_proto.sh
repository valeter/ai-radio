mkdir -p generated

rm -rf generated/*

mkdir -p proto

git clone https://github.com/googleapis/googleapis.git proto/googleapis
git clone https://github.com/yandex-cloud/cloudapi.git proto/cloudapi

protoc --proto_path=proto/googleapis --proto_path=proto/cloudapi --go_out=generated --go_opt=paths=source_relative --go-grpc_out=generated --go-grpc_opt=paths=source_relative proto/cloudapi/yandex/cloud/ai/tts/v3/*