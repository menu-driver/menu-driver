require 'spec_helper'
require_relative '../lambda'

describe "Lambda handler" do

  context "gets menu data", :vcr do

    it 'requires a location_id parameter' do

      response = 
        generate_location(
          event:JSON.parse(
            File.read('spec/lambda_events/no_location_id.json')),
          context:{})
          
      expect(response[:statusCode]).to eq 400

      message = JSON.parse(response[:body]).to_dot.message

      expect(message).to match(/location id/i)

    end

    # TODO: This is not that important but it might make maintaining menus
    # over time a little simpler.
    # pending 'returns a 404 if the given location does not exist in ' +
    #   'Single Platform' do
    #   fail
    # end

    it 'redirects to the HTML menu on S3 after generating it' do

      response = 
        generate_location(
          event:JSON.parse(
            File.read('spec/lambda_events/location_id_hakkasan_mayfair.json')),
          context:{})
          
      expect(response[:statusCode]).to eq 302
      expect(URI(response[:headers][:Location]).path).
        to eq '/test.menus.hakkasangroup.com/hakkasan-mayfair/index.html'

    end

  end
  
  context 'parameters', :vcr do

    it 'passes URL query parameters to the HTML generator' do

      expect_any_instance_of(SinglePlatform).
        to receive(:generate_menus_html).with(hash_including(:passthrough => 'SIERRA'))

      generate_location(
        event:JSON.parse(
          File.read('spec/lambda_events/location_id_hakkasan_mayfair_with_passthrough_parameter.json')),
        context:{})

    end

  end

end