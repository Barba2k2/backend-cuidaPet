# CuidaPet API: Backend para Serviços de Petshops e Clínicas Veterinárias

## Visão Geral
Este projeto envolve o desenvolvimento de uma API de backend, destinada a conectar petshops, clínicas veterinárias e donos de pets. A API facilita operações como agendamento de banho e tosa, hospedagem animal e consultas veterinárias, permitindo que os usuários escolham prestadores de serviços com base em localização, disponibilidade e avaliações.

## Funcionalidades
- **Cadastro e Gerenciamento de Serviços:** Petshops e clínicas podem cadastrar e gerenciar seus serviços, definindo preços e horários disponíveis através de um painel administrativo.
- **Comunicação Direta:** Um módulo de comunicação permite trocas de mensagens em tempo real entre clientes e prestadores, melhorando a eficiência e a experiência do usuário.
- **Autenticação Segura:** Implementação de sistemas de autenticação para garantir a segurança dos dados dos usuários.

## Tecnologias
A API será construída utilizando:
- Tecnologias modernas de backend.
- Práticas recomendadas de desenvolvimento de software.
- APIs RESTful bem documentadas para facilitar a integração com outros sistemas.

## Segurança e Performance
Foco em segurança, escalabilidade e facilidade de integração, garantindo uma base sólida para futuras expansões e desenvolvimento do frontend do aplicativo.

## Documentação
A documentação completa estará disponível para facilitar a integração e utilização da API por desenvolvedores e parceiros comerciais.

---

A server app built using [Shelf](https://pub.dev/packages/shelf),
configured to enable running with [Docker](https://www.docker.com/).

This sample code handles HTTP GET requests to `/` and `/echo/<message>`

# Running the sample

## Running with the Dart SDK

You can run the example with the [Dart SDK](https://dart.dev/get-dart)
like this:

```
$ dart run bin/server.dart
Server listening on port 8080
```

And then from a second terminal:
```
$ curl http://0.0.0.0:8080
Hello, World!
$ curl http://0.0.0.0:8080/echo/I_love_Dart
I_love_Dart
```

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```
$ docker build . -t myserver
$ docker run -it -p 8080:8080 myserver
Server listening on port 8080
```

And then from a second terminal:
```
$ curl http://0.0.0.0:8080
Hello, World!
$ curl http://0.0.0.0:8080/echo/I_love_Dart
I_love_Dart
```

You should see the logging printed in the first terminal:
```
2021-05-06T15:47:04.620417  0:00:00.000158 GET     [200] /
2021-05-06T15:47:08.392928  0:00:00.001216 GET     [200] /echo/I_love_Dart
```
