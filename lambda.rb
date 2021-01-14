$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'single-platform'
require 'addressable/uri'
require 'erb'

require "menudriver/options-files"

# AWS Lambda function handler.
def generate_location(event:, context:)

  $logger.info 'Starting HTML menu generation...'

  location_id =
    if event['queryStringParameters']
      event['queryStringParameters']['location_id']
    end

  unless location_id

    $logger.info 'No location_id parameter provided.  Returning 400 error response.'

    {
      statusCode: 400,
      body: {
        message: 'Please provide the Single Platform location ID in the query string parameter "location_id"'
      }.to_json
    }

  else

    # Combine URL query string parameters with the
    # parameters to the HTML generation method.
    options =
      event['queryStringParameters'].
        transform_keys{|key| key.to_sym } || {}

    # Add in the options from the options.yml files.
    # TODO: DRY this code that's duplicated in the Thor menudriver CLI file.
    # Maybe move this functionality into the options class.
    all_options = options.dup
    if options_from_files = MenuDriver::OptionsFiles.new.menu_options(location_id)
      $logger.info "Options from files: #{options_from_files}"
      all_options.merge! options_from_files
      if options_from_files['location']
        location_id = options_from_files['location']
      end
    end

    $logger.debug "location_id: " + location_id.ai
    $logger.debug "all_options: " + all_options.ai

    # Use the API to get the menu data.
    s3_object = SinglePlatform.new(
          client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
          secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
        ).publish_menu_content(location_id:location_id, **all_options)

    $logger.info "Redirecting to HTML at: #{s3_object.public_url}"

    {
      statusCode: 302,
      headers: {
        'Location': s3_object.public_url
      },
      body: nil
    }

  end

end
