# Menu Driver

[![Coverage Status](https://coveralls.io/repos/github/VenueDriver/menu-driver/badge.svg?branch=production)](https://coveralls.io/github/VenueDriver/menu-driver?branch=production)

A tool for generating web menus from structured menu data and branded templates.  Originally developed by Hakkasan Group in response to the COVID-19 pandemic for creating high-performance, accessible web menus for use with QR codes in restaurants.

Menu Driver connects to a data source, like Single Platform, and generates all of the HTML, CSS and Javascript necessary for presenting an interactive web representation of the restaurant menus.

![Menu Driver Overall](https://raw.githubusercontent.com/menu-driver/menu-driver/production/docs/images/Menu Driver Overall.png)

The output is static and doesn't require a back end, and can be served from a fast, reliable and inexpensive static web host like Amazon S3.  The web menus are aimed especially at mobile users in the restaurants, but they're also intended for desktop and tablet viewers of the restaurant web site.

## CLI

The simplest way to run Menu Driver is with the CLI tool:

    menudriver generate restaurant-1 --theme=our-awesome-resataurants

## Serverless Microservice

You can also run it in the cloud in AWS Lambda, so that you can enable restaurant marketers to update menus for themselves.  While you still maintain and operate the code that they use.

## Development

### Use the same Ruby version as AWS

Make sure that you're using Ruby 2.5, the version that the AWS runtime will use when this runs in Lambda.  There is an `.rvmrc` file for locking the Ruby version to 2.5.0.  You might need to install [RVM](https://rvm.io/rvm/install).

### Set up AWS resources for development

SAM Local cannot manage local S3 buckets or DynamoDB tables for development.
You have to either set up local simulations manually, or you can use actual
cloud AWS services for development instead of trying to simulate them.

You can simulate AWS services locally using Localstack or whatever.  But it's
a lot of work.  Maintaining a simulation of AWS becomes part of your job for
your project.  But why?  Why not just work on your project, and let AWS
provide AWS services?

For developement, this project uses real AWS services intead of trying to
simulate them locally.  So that all of the code in this project is about the
project, and so that you don't have to learn how to run a local simulation of
AWS to work on this code.

To use SAM to set up development resources in the cloud:

    sam build && rake sam:deploy

You won't have a value in your `samconfig.toml` SAM [configuration file](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-config.html) for the `s3_bucket`, so the Rake task will invoke the ["guided"](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-deploy.html) deployment feature in `sam deploy`.

SAM will ask you a series of questions so that it can build a configuration file.  This is where you give it your Single Platform API secrets.

You should see something like this:

    $ sam deploy -g

    Configuring SAM deploy
    ======================

            Looking for samconfig.toml :  Found
            Reading default arguments  :  Success

            Setting default arguments for 'sam deploy'
            =========================================
            Stack Name [menu-driver-development]:

The stack name will be pre-filled for you.  You don't want to override that.  Every time you run the Rake task to deploy, Ruby logic will set up the stack name and S3 prefix values and also the parameter override for the "Stack" parameter.  Anything you specify here will be overwritten by that process.

Next, it will ask you for the AWS region you'd like you use, and a few other options.  Whatever you tell it will be recorded in the `samconfig.toml` file and will be used for future deployments.

You will reach a point where it will ask you for the value for the Stack parameter:

        Setting default arguments for 'sam deploy'
        =========================================
        Stack Name [menu-driver-test]:
        AWS Region [us-east-1]:
        Parameter Stack []:

Plese type `development`.  I wish that I could pre-fill that for you but the guided deployment feature of SAM doesn't seem to have a way to do that.  Sorry.  For future deployments, Ruby logic in the `sam:deploy` Rake task will automatically update the stack name in the configuration file based on the `STACK` environment variable, or passed as an argument.

After that, it will ask you for your Single Platform secrets:

        Setting default arguments for 'sam deploy'
        =========================================
        Stack Name [menu-driver-development]:
        AWS Region [us-east-1]:
        Parameter Stack []: development
        Parameter SinglePlatformClientID []:

Your secrets will be recorded in the `samconfig.toml` file, and if you need to update them in the future then edit that file.  There is only one copy of the secets in your project and it's in that SAM configuration file.

SAM should deploy to the `menu-driver-development` stack in CloudFormation.  More importantly, SAM will set up the S3 bucket used for deployments for you and record the location of that bucket in your SAM config file.  The next time that you deploy, just use:

    rake sam:deploy

Or, to build first:

    sam build && rake sam:deploy

### Deploying other stacks

The Rake task wraps `sam deploy` in the Ruby logic for setting up the stack name and other things based either on a name from the `STACK` environment variable, or a parameter passed to the Rake task:

    STACK=main rake sam:deploy

or:

    rake sam:deploy[main]

### Running the code

#### Directly

You can generate menu HTML and store it on S3 using the Single Platform
configuration information stored in your ````samconfig.toml```` without using any SAM or Lambda stuff.  You have to do a SAM build every time you want to see different output if you run the code through SAM Local.  If all that you really want is to generate HTML while you're working on menu templates, then run the HTML generation code directly with this Rake task:

    rake generate[hakkasan-mayfair]

Give it the location in the brackets as a Rake argument.

### Use the CLI

For more flexibility, the command-line interface `menudriver` provides parameters that are connected to features in the Standard Theme.

    bundle exec exe/menudriver generate hakkasan-mayfair --theme=hakkasan.theme --vertical-grid

#### Invoke the Lambda function through SAM Local

Invoke individual Lambda functions using the canned Lambda events in the specs:

    sam local invoke MenusDataFunction --event spec/lambda_events/location_id_hakkasan_mayfair.json

That will invoke the Lambda function that will load your Single Platform credentials using dotenv, and will then connect with the Single Platform API to get the raw menu data for the location specified in the `event.json` file (Hakkasan Mayfair) and then it will return the data in JSON format.

#### Send an HTTP request to the Lambda function in SAM Local

You can start the AWS SAM CLI's HTTP server for local development with:

    rake sam:local:start

Then you can send HTTP requests:

    curl 'http://127.0.0.1:8080/menus_data?location_id=hakkasan-mayfair'

That will do the exact same thing as the previous example of calling the `MenusDataFunction` directly.

## Tests

You may have already deployed a test stack above, but if you haven't then do that by deploying a CloudFormation stack for `menu-driver-test` with:

    rake sam:deploy[test]

To run the tests:

    rake test

To run an individual spec:

    rspec spec/single_platform_spec.rb -e "gets JSON through an HTTP request"

That runs the same `MenusDataFunction` that's invoked in above examples through SAM Local, both triggered as a function with an event passed to it through a JSON file, and also accessed through HTTP.  Running the spec through RSpec calls the same code for getting the same menu data for the same location, but it also checks the result.  The actual HTTP call to the actual API is mocked through VCR, so it won't really call the Single Platform API.
