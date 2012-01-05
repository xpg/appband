require 'rubygems'

namespace :spec do
  desc "Run the AppBand Spec Server"
  task :server do
    server_path = File.dirname(__FILE__) + '/Specs/Server/server.rb'
    system("ruby #{server_path}")
  end
end

task :default => 'spec:server'

