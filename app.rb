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
          result = system("yt-dlp -f \"bv*[height<=1080][vcodec~='^((he|a)vc|h26[45])']+ba[ext=m4a]/b[height<=1080][vcodec~='^((he|a)vc|h26[45])']/bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b\" --recode-video \"mp4\" --audio-format \"aac\" -o '/downloads/%(uploader)s/%(title)s.%(ext)s' #{video.url}")
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
