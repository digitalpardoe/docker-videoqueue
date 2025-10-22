FROM ruby:3.4.7-slim-trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 pipx ffmpeg build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN pipx install yt-dlp[default]
RUN curl -fsSL https://deno.land/install.sh | sh

ENV PATH="$PATH:/root/.local/bin:/root/.deno/bin"

COPY . /app
WORKDIR /app

RUN bundle install

RUN mkdir -p /.cache/yt-dlp && chmod -R 666 /.cache/yt-dlp

CMD [ "/app/entrypoint.sh" ]

LABEL org.opencontainers.image.source=https://github.com/digitalpardoe/docker-videoqueue
