# NTSS MQTT Message Receiver

> このモジュールはAWS IoTのLambda ルールにより呼び出されるAWS Lambda Functionです。

## ローカルでの動作環境

### for Mac

スタブのサーバを起動

```sh
node serve.js
```

[docker-lambda](https://github.com/lambci/docker-lambda)を使ってエミュレートした環境で実行する。

```sh
$ docker run -e END_POINT_URL=http://docker.for.mac.localhost:3000/api/alerts -v "$PWD":/var/task lambci/lambda index.iotHandler '{"a": "A"}'
```
