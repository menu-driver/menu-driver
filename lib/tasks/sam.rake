# Load secrets from the samconfig.toml file that SAM will use for deployment.
require 'toml'
require 'deep_merge'
require 'pry'

namespace :sam do

  desc 'Deploy to AWS with secrets, to the stack name set in CLOUD_STACK (or "development")'
  task :deploy do

    current_stack = ENV['CLOUD_STACK'] || 'development'
    
    # If there is a config file alredy then massage it to adjust it
    # for the current CLOUD_STACK context.
    if File.exist? filename = 'samconfig.toml'
      # Read the SAM deployment configuration file into a hash.
      config = TOML.load_file(filename)
  
      # Massage values that depend on the current stack.
      config.deep_merge!(
        {'default' => {'deploy' => {'parameters' => {
          'stack_name' => "menu-driver-#{current_stack}",
          's3_prefix' => "menu-driver-#{current_stack}"
        }}}})
      config['default']['deploy']['parameters']['parameter_overrides'].
        gsub!(/Stack\=\S+/, 'Stack=' + current_stack)
  
      # Write it back to the same file.
      File.write(
        'samconfig.toml',
        TOML::Generator.new(config).body
      )
  
      system 'sam deploy'

    else
      
      # If there is not already a SAM config file, then do a "guided" deployment
      # to create one.
      command = "sam deploy -g --stack-name menu-driver-#{current_stack}" +
        " --parameter-overrides=\"Stack=#{current_stack}\""
      puts 'running: ' + command
      puts system command
      
    end
  end

  namespace :local do

    desc "Start the SAM Local HTTP server."
    task :start do
      command = <<-EOC
        sam local start-api -p 8080 --docker-network menu-driver --parameter-overrides "SinglePlatformClientID=#{ENV['SP_CLIENT_ID']},SinglePlatformClientSecret=#{ENV['SP_CLIENT_SECRET']},Stack=development" &
      EOC
      puts 'running: ' + command
      puts system command
    end
  
  end

end