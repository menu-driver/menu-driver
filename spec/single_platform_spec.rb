require 'spec_helper'
require_relative '../lib/single-platform'

describe "Single Platform" do
  
  context "gets menu data", :vcr do

    it 'gets JSON through an HTTP request' do
      VCR.use_cassette('menus') do

        single_platform = SinglePlatform.new(
          client_id: ENV['SP_CLIENT_ID'],
          secret:    ENV['SP_CLIENT_SECRET']
        )
      
        menus = single_platform.menus(
          location_id:'hakkasan-mayfair')

        expect(menus.count).to eq 17
        expect(menus.first.name).to eq 'A la Carte'
        expect(menus.first.sections.count).to eq 11

      end
    end

    it 'gets JSON for the "short" format' do
      VCR.use_cassette('menus-short') do

        single_platform = SinglePlatform.new(
          client_id: ENV['SP_CLIENT_ID'],
          secret:    ENV['SP_CLIENT_SECRET']
        )
      
        menus = single_platform.menus(
          location_id: 'hakkasan-mayfair',
          
          # Added this extra parameter.
          format:      'short'
        )

        # The "Short Menu".
        # http://docs.singleplatform.com/spv3/publisher_api/
        expect(menus.count).to eq 1
        expect(menus.first.name).to eq 'A la Carte'

      end
    end

  end

end