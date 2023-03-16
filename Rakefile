require 'rubygems'
require 'bundler'

Bundler.require

require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app"
  end
end
