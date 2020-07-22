require 'dotenv/load'

namespace :server do

  desc "Start the SAM Local HTTP server."
  task :start do
    command = <<-EOC
      sam local start-api -p 8080 --docker-network menu-driver --parameter-overrides "SinglePlatformClientID=#{ENV['SP_CLIENT_ID']},SinglePlatformClientSecret=#{ENV['SP_CLIENT_SECRET']},Environment=dev" &
    EOC
    puts 'running: ' + command
    puts system command
  end

end