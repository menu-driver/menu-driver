# Load the secrets from the .env if one exists.
# In CodeShip or another CI, the same environment variables will be set up in
# some way other than .env but they still need to be set up.
require 'dotenv/load'

namespace :sam do

  desc "Build with SAM for testing or deploying."
  task :build do
    command = <<-EOC
      sam build
    EOC
    puts 'running: ' + command
    puts system command
  end

  desc "Deploy to AWS Lambda / DynamoDB with SAM."
  task :deploy do
    environment = `git branch`.gsub(/^\*\s*/,'')
    command = <<-EOC
      sam deploy -g --parameter-overrides "SinglePlatformClientID=#{ENV['SP_CLIENT_ID']},SinglePlatformClientSecret=#{ENV['SP_CLIENT_SECRET']},Environment=#{environment}"
    EOC
    puts 'running: ' + command
    puts system command
  end

end