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
          result = system("yt-dlp -f bestvideo[ext=mp4][vcodec!*=av01]+bestaudio[ext=m4a]/best[ext=mp4]/best -o '/downloads/%(uploader)s/%(title)s.%(ext)s' #{video.url}")
          if result
            puts "Finished downloading #{video.url}!"
            video.downloaded = true
            video.save
          end
        rescue => e
          puts "Error: #{e}"
        end
      end

      sleep 60
    end
  end
end

before do
  content_type :json
end

post '/add' do
  payload = JSON.parse(request.body.read).symbolize_keys
  Video.create(url: payload[:url], downloaded: false)
end
