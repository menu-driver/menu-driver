require "menudriver/version"
require "menudriver/options-files"

require 'thor'
require 'colorized_string'
require 'pry'

# Load secrets from the samconfig.toml file that SAM will use for deployment.
require 'single-platform'
require 'sam-parameter-environment'

module MenuDriver
  class Error < StandardError; end

  class CLI < Thor

    def self.exit_on_failure?
      true
    end

    desc "generate [location]", "generate restaurant menu HTML data for the location"
    option :name, :type => :string, :desc => 'output folder name (defaults to the location)'
    option :theme, :type => :string, :desc => 'name (not path) of theme folder for ERB HTML templates.'
    option :stack, :type => :string, :desc => 'The name of the CloudFront stack that was used to generate the S3 bucket where you want to deploy output. Example: "production".  Default: "staging".', :default => 'staging'
    option :vertical_grid, :type => :boolean, :default => false, :desc => 'Show the vertical rhythym with horizontal lines showing the line height.'
    option :cache, :type => :boolean, :default => false, :aliases => :c, :desc => 'Cache the menu data from the API and use it next time if available.'
    option :data_file, :type => :string, :desc => 'file name for JSON menu data file'
    option :category, :type => :string, :default => nil, :desc => 'name of a category for generating a one-category menu'
    option :menu, :type => :string, :default => nil, :desc => 'include only menus matching this comma-separated string of names or IDs'
    def generate(location)
      puts ColorizedString[' Generating HTML menus for location: '].black.on_light_blue + ' ' + location

      all_options = options.dup
      if options_from_files = MenuDriver::OptionsFiles.new.menu_options(location)
        $logger.info "Options from files: #{options_from_files}"
        all_options.merge! options_from_files
        if options_from_files['location']
          all_options['output_file'] = location
          location = options_from_files['location']
        end
      end

      begin
        SamParameterEnvironment.load

        # Always use the stack specified by the CLI option (default: staging)
        # instead of the one specified in the samconfig.toml file for AWS Lambda.
        ENV['STACK'] = options['stack']

        SinglePlatform.new(
          client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
          secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
        ).publish_menu_content(
          location_id: location,
          name: all_options[:name] || location,
          **all_options.transform_keys { |key| key.to_sym })
      rescue => exception
        puts ColorizedString[' ERROR '].black.on_red + ' ' + exception.ai
        puts ColorizedString[' trace '].black.on_red
        raise
      end

    end

  end

end
