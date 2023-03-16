FROM ruby:3.1.2-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip ffmpeg build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade yt-dlp

COPY . /app
WORKDIR /app

RUN rm -rf Dockerfile data/*.sqlite3 && \
    bundle install

RUN mkdir -p /.cache/yt-dlp && chmod -R 666 /.cache/yt-dlp
RUN chmod 666 db/schema.rb

CMD [ "/app/entrypoint.sh" ]
