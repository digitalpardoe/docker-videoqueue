Acts as an API to send YouTube URLs to which will be automatically downloaded by `yt-dlp` for watching later (maybe with Plex).

You should be able to send it any URL that `yt-dlp` can handle but it's only tested with YouTube.

It also has no error handling so make sure you're comfortable editing SQLite databases if you send an invalid URL to the API (or just delete the database and start again). 

## Usage

```
docker run \
  --restart unless-stopped \
  -p 4567:4567 \
  -v </path/to/data/folder>:/app/data \
  -v </path/to/media/folder>:/downloads \
  digitalpardoe/videoqueue
```

Send requests to `<your_ip>:<your_port>/add`, it expects a `POST` request containing JSON in the format `{ url: "<youtube_url>" }` - this works well with Apple's Shortcuts app.

## Parameters

* `-p 4567:4567` - the port you'd like to expose the API on
* `-v /app/data` - folder to store the database (you can leave this out if you don't mind possibly losing your queue)
* `-v /downloads` - the folder videos are downloaded into
