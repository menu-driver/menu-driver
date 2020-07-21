# Menu Driver

Serverless microservice built with Ruby for hosting web restaurant menus based on data from the Single Platform API.

[![Coverage Status](https://coveralls.io/repos/github/VenueDriver/menu-driver/badge.svg?branch=master)](https://coveralls.io/github/VenueDriver/menu-driver?branch=master)

## Development

### Use the same Ruby version as AWS

Make sure that you're using Ruby 2.5, the version that the AWS runtime will use when this runs in Lambda.  There is an `.rvmrc` file for locking the Ruby version to 2.5.7.  You might need to install [RVM](https://rvm.io/rvm/install).

### Set up Single Platform secrets

You'll need the credentials for a  Single Platform account in your `.env` file:

    SP_CLIENT_ID=XXXXXX
    SP_CLIENT_SECRET=XXXXXX

### Set up local DynamoDB tables

SAM Local cannot manage local DynamoDB tables for development.  You have to set them up manually.

First, you will need [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html).  This will install it:

    rake dynamodb:setup

You should only need to do that one time.

If you have already done that once and downloaded the DynamoDB container before, then you can run the existing container with:

    rake dynamodb:start

To scan the current contents of your ```menus``` table:

    rake dynamodb:scan_menus

### AWS SAM CLI

Make sure that you have the [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) from Amazon Web Services.

Invoke individual Lambda functions using the canned Lambda events in the specs:

    sam local invoke MenusDataFunction --event spec/lambda_events/location_id_hakkasan_mayfair.json

That will invoke the Lambda function that will load your Single Platform credentials using dotenv, and will then connect with the Single Platform API to get the raw menu data for the location specified in the `event.json` file (Hakkasan Mayfair) and then it will return the data in JSON format.

You can start the AWS SAM CLI's HTTP server for local development with:

    rake server:start

Then you can send HTTP requests:

    curl 'http://127.0.0.1:8080/menus_data?location_id=hakkasan-mayfair'

That will do the exact same thing as the previous example of calling the `MenusDataFunction` directly.

### Rake tasks for starting, stopping, restarting

These Rake tasks help with starting an managing a development environment:

    rake develop:start
    
    rake develop:restart
    
    rake develop:stop

## Tests

To run the tests:

    rake test

Some of the tests depend on DynamoDB, so make sure that you `rake develop:start` or `rake dynamodb:start` first.

To run an individual spec:

    rspec spec/single_platform_spec.rb -e "gets JSON through an HTTP request" -f d

That runs the same `MenusDataFunction` that's invoked in above examples through SAM Local, both triggered as a function with an event passed to it through a JSON file, and also accessed through HTTP.  Running the spec through RSpec calls the same code for getting the same menu data for the same location, but it also checks the result.  The actual HTTP call to the actual API is mocked through VCR, so it won't really call the Single Platform API.