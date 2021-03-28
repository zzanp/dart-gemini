# Gemini Dart server

A very simple [Gemini](https://gemini.circumlunar.space/) server written in [Dart](https://dart.dev/)

## Running

If you want, edit [config.yaml](./config.yaml), generate SSL certificate (for local testing
run `openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365`) and just run

```shell
pub run geminisvr
```
