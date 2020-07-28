# Load secrets from the samconfig.toml file that SAM will use for deployment.
require 'single-platform'
require 'sam-parameter-environment'

desc 'Generate menu HTML on S3 based on the SAM config file settings'
task :generate, [:location_id] do |task, args|

  SamParameterEnvironment.load

  SinglePlatform.new(
    client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
    secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
  ).generate_html_menus(location_id:args['location_id'])

end

