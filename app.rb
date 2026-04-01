require 'rubygems'
require 'bundler'

Bundler.require

puts "Starting videoqueue..."
puts "Running as user #{Process.uid} and group #{Process.gid}."

Video = Struct.new('Video', :url, :downloaded, :retries)

videos = []
videos_mutex = Mutex.new

Thread.new do
  puts "Starting download thread..."
  loop do
    video = nil
    videos_mutex.synchronize do
      video = videos.find { |v| v.downloaded == false }
    end

    if video.nil?
      puts "No videos to download!"
    else
      begin
        result = system("yt-dlp --newline -f \"bv[height<=1080][vcodec~='^((he|a)vc|h26[45])']+ba[acodec~='^(aac|mp4a)']/bv[height<=1080]+ba/bv+ba\" -o \"/downloads/%(uploader)s/%(upload_date)s - %(title)s.%(ext)s\" \"#{video.url}\"")
        if result
          puts "Finished downloading #{video.url}!"
          videos_mutex.synchronize do
            video.downloaded = true
          end
        else
          handle_error(video)
        end
      rescue => e
        handle_error(video)
      end
    end

    sleep 60
  end
end

def handle_error(video)
  puts "Error downloading #{video.url}!"
  videos_mutex.synchronize do
    video.retries += 1
    if video.retries >= 3
      puts "Giving up on #{video.url}!"
      video.downloaded = true
    end
  end
end

before do
  content_type :json
end

post '/add' do
  payload = JSON.parse(request.body.read)
  videos_mutex.synchronize do
    videos << Video.new(payload['url'], false, 0)
  end
  status 201
end
