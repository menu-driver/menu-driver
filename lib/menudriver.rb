require "menudriver/version"

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
    option :theme, :type => :string, :desc => 'name (not path) of theme folder for ERB HTML templates.'
    option :vertical_grid, :type => :boolean, :default => false, :desc => 'Show the vertical rhythym with horizontal lines showing the line height.'
    option :cache, :type => :boolean, :default => false, :aliases => :c, :desc => 'Cache the menu data from the API and use it next time if available.'
    option :data_file, :type => :string, :desc => 'file name for JSON menu data file'
    option :category, :type => :string, :default => nil, :desc => 'name of a category for generating a one-category menu'
    def generate(location)
      puts ColorizedString[' Generating HTML menus for location: '].black.on_light_blue + ' ' + location

      begin
        SamParameterEnvironment.load

        SinglePlatform.new(
          client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
          secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
        ).publish_menu_content(
          location_id:location,
          **options.transform_keys { |key| key.to_sym })
      rescue => exception
        puts ColorizedString[' ERROR '].black.on_red + ' ' + exception.ai
        puts ColorizedString[' trace '].black.on_red
        raise
      end

    end

  end

end
