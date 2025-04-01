require 'rubygems'
require 'bundler'

Bundler.require

if File.basename($0) != 'rake'
  puts "Starting videoqueue..."
  puts "Running as user #{Process.uid} and group #{Process.gid}."
end

set :bind, '0.0.0.0'
set :database, { adapter: "sqlite3", database: "data/videoqueue.sqlite3" }

class Video < ActiveRecord::Base
end

if File.basename($0) != 'rake'
  Thread.new do
    puts "Starting download thread..."
    loop do
      video = Video.where(downloaded: false).first
      if video.nil?
        puts "No videos to download!"
      else
        begin
          result = system("yt-dlp -f \"bv[height<=1080][vcodec~='^((he|a)vc|h26[45])']+ba[acodec~='^(aac|mp4a)']/bv[height<=1080]+ba/bv+ba\" -o \"/downloads/%(uploader)s/%(upload_date)s - %(title)s.%(ext)s\" \"#{video.url}\"")
          if result
            puts "Finished downloading #{video.url}!"
            video.downloaded = true
            video.save
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
end

def handle_error(video)
  puts "Error downloading #{video.url}!"
  video.increment!(:retries, 1)
  if video.retries >= 3
    puts "Giving up on #{video.url}!"
    video.downloaded = true
  end
  video.save
end

before do
  content_type :json
end

post '/add' do
  payload = JSON.parse(request.body.read).symbolize_keys
  Video.create(url: payload[:url], downloaded: false)
end
