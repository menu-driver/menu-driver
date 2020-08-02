$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'single-platform'
require 'addressable/uri'
require 'erb'

# AWS Lambda function handler.
def menus_data(event:, context:)

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
        transform_keys{|key| key.to_sym }

    # Use the API to get the menu data.
    s3_object = SinglePlatform.new(
          client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
          secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
        ).publish_menu_content(location_id:location_id, **options)

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
