FROM golang:1.25.3-alpine AS builder

WORKDIR /build

COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o videoqueue main.go

FROM alpine:3.19

RUN apk add --no-cache python3 py3-pip ffmpeg curl ca-certificates

RUN pip3 install --no-cache-dir --break-system-packages yt-dlp[default]
RUN curl -fsSL https://deno.land/install.sh | sh 

RUN apk del curl && \
    rm -rf /var/cache/apk/* /root/.cache

ENV PATH="$PATH:/root/.deno/bin"

COPY --from=builder /build/videoqueue /app/videoqueue
COPY entrypoint.sh /app/entrypoint.sh

WORKDIR /app

RUN mkdir -p /.cache/yt-dlp && chmod -R 666 /.cache/yt-dlp

CMD [ "/app/entrypoint.sh" ]

LABEL org.opencontainers.image.source=https://github.com/digitalpardoe/docker-videoqueue
