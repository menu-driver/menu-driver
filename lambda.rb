$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'single-platform'

# AWS Lambda function handler.
#
# Parameters
# ----------
# event: Hash, required
#     API Gateway Lambda Proxy Input Format
#     Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
#
# context: object, required
#     Lambda Context runtime methods and attributes
#     Context doc: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html
#
# Returns
# ------
# API Gateway Lambda Proxy Output Format: dict
#     'statusCode' and 'body' are required
#     # api-gateway-simple-proxy-for-lambda-output-format
#     Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
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

    # Use the API to get the menu data.
    single_platform = SinglePlatform.new(
          client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
          secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
        )

    menus_html = single_platform.generate_menus_html(
      location_id: location_id)

    $logger.info "Storing HTML menu for location: #{location_id}"

    s3 = Aws::S3::Resource.new
    s3_object = s3.bucket('menu-driver-'+ENV['STACK_NAME']).object(location_id)
    s3_object.put(body:menus_html, content_type: 'text/html')

    $logger.info "Redirecting to HTML at: #{s3_object.public_url}"

    # s3.bucket('my.bucket.com').object('key')
    #   .public_url(virtual_host: true)
    # #=> "http://my.bucket.com/key"

    {
      statusCode: 302,
      headers: {
        'Location': s3_object.public_url
      },
      body: nil
    }
    
  end
  
end
