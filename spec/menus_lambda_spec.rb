require 'spec_helper'
require_relative '../lambda'

describe "Lambda handler" do

  context "gets menu data", :vcr do

    it 'requires a location_id parameter' do

      response = 
        menus_data(
          event:JSON.parse(
            File.read('spec/lambda_events/no_location_id.json')),
          context:{})
          
      expect(response[:statusCode]).to eq 400

      message = JSON.parse(response[:body]).to_dot.message

      expect(message).to match(/location id/i)

    end

    pending 'returns a 404 if the given location does not exist in Single Platform' do
      fail
    end

    it 'redirects to the HTML menu on S3 after generating it' do

      expect_any_instance_of(Aws::S3::Object).
        to receive(:put)

      response = 
        menus_data(
          event:JSON.parse(
            File.read('spec/lambda_events/location_id_hakkasan_mayfair.json')),
          context:{})
          
      expect(response[:statusCode]).to eq 302
      expect(URI(response[:headers][:Location]).path).
        to eq '/hakkasan-mayfair'

    end
    
    pending 'redirects to the HTML menu on a custom domain' do
      fail
    end

  end

end