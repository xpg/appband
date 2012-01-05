#!/usr/bin/env ruby
# AppBand Specs Server

require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'ruby-debug'
Debugger.start

# Import the Spec Server
$: << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

class AppBand::SpecServer < Sinatra::Base
  self.app_file = __FILE__
  
  configure do
    register Sinatra::Reloader
    set :logging, true
    set :dump_errors, true
    set :public_folder, Proc.new { File.join(root, '../Fixtures') }
  end
  
  get '/' do
    content_type 'application/json'
    {'status' => 'ok'}.to_json
  end
end
