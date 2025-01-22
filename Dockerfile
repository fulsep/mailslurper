ARG ARCH=
FROM ${ARCH}golang:1.22.11-alpine3.21 AS builder

LABEL maintainer="erguotou525@gmail.compute"

RUN apk --no-cache add git libc-dev gcc
RUN go install github.com/mjibson/esc@latest # TODO: Consider using native file embedding

COPY . /go/src/github.com/mailslurper/mailslurper
WORKDIR /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper

RUN go get
RUN go generate
RUN go build

ARG ARCH=
FROM ${ARCH}alpine:3.21

RUN apk add --no-cache ca-certificates \
  && echo -e '{\n\
  "wwwAddress": "0.0.0.0",\n\
  "wwwPort": 8080,\n\
  "wwwPublicURL": "",\n\
  "serviceAddress": "0.0.0.0",\n\
  "servicePort": 8085,\n\
  "servicePublicURL": "",\n\
  "smtpAddress": "0.0.0.0",\n\
  "smtpPort": 2500,\n\
  "dbEngine": "SQLite",\n\
  "dbHost": "",\n\
  "dbPort": 0,\n\
  "dbDatabase": "./mailslurper.db",\n\
  "dbUserName": "",\n\
  "dbPassword": "",\n\
  "maxWorkers": 1000,\n\
  "autoStartBrowser": false,\n\
  "keyFile": "",\n\
  "certFile": "",\n\
  "adminKeyFile": "",\n\
  "adminCertFile": ""\n\
  }'\
  >> config.json

COPY --from=builder /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper/mailslurper mailslurper

EXPOSE 8080 8085 2500

CMD ["./mailslurper"]
