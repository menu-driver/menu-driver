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

    rake dynamodb:run

To scan the current contents of your ```menus``` table:

    rake dynamodb:scan_menus

### AWS SAM CLI

Make sure that you have the [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) from Amazon Web Services.

You can start the AWS SAM CLI's HTTP server for local development with:

    rake server:start

### Rake tasks for starting, stopping, restarting

These Rake tasks help with starting an managing a development environment:

    rake develop:start
    
    rake develop:restart
    
    rake develop:stop

## Tests

To run the tests:

    rake test

The tests depend on DynamoDB, so make sure that you `rake develop:start` or `rake dynamodb:start` first.