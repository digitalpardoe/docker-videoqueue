FROM ruby:3.1.6-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip ffmpeg build-essential curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade yt-dlp[default]
RUN curl -fsSL https://deno.land/install.sh | sh

ENV PATH="$PATH:/root/.deno/bin"

COPY . /app
WORKDIR /app

RUN bundle install

RUN mkdir -p /.cache/yt-dlp && chmod -R 666 /.cache/yt-dlp
RUN chmod 666 db/schema.rb

CMD [ "/app/entrypoint.sh" ]

LABEL org.opencontainers.image.source=https://github.com/digitalpardoe/docker-videoqueue
