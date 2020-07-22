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

  location_id =
    if event['queryStringParameters']
      event['queryStringParameters']['location_id']
    end
  
  unless location_id
    {
      statusCode: 400,
      body: {
        message: "Please provide the Single Platform location ID in the query string parameter \"location_id\"",
      }.to_json
    }
  else

    # Use the API (or DynamoDB cache) to get the menu data.
    single_platform = SinglePlatform.new(
          client_id: ENV['SP_CLIENT_ID'],
          secret:    ENV['SP_CLIENT_SECRET']
        )
      
    menus = single_platform.menus(
      location_id: location_id)

    {
      statusCode: 200,
      body: {
        message: menus
      }.to_json
    }
  end
end
