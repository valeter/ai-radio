rm -rf proto/generated
mkdir -p proto/generated/go
mkdir -p proto/generated/python

if [ ! -d "proto/googleapis" ]; then
  git clone https://github.com/googleapis/googleapis.git proto/googleapis
fi
if [ ! -d "proto/cloudapi" ]; then
  git clone https://github.com/yandex-cloud/cloudapi.git proto/cloudapi
fi


# go
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


#python
python -m grpc_tools.protoc \
    -I=proto/src \
    -I=proto/cloudapi \
    -I=proto/googleapis \
    --python_out=proto/generated/python \
    --grpc_python_out=proto/generated/python \
    $(find proto/cloudapi/yandex/cloud/ai/tts/v3 -name '*.proto')

python -m grpc_tools.protoc \
    -I=proto/src \
    -I=proto/cloudapi \
    -I=proto/googleapis \
    --python_out=proto/generated/python \
    --grpc_python_out=proto/generated/python \
    $(find proto/src -name '*.proto')

rm -rf python/fetch-news/generated
mkdir -p python/fetch-news/generated
cp -r proto/generated/python/* python/fetch-news/generated