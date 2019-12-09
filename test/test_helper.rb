require 'bundler/setup'
Bundler.require :default, :development
Dotenv.load('.env')
require "minitest/autorun"
