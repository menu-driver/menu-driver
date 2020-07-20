require 'spec_helper'
require_relative '../lib/single-platform'

describe "Single Platform" do
  
  context "gets menu data", :vcr do

    it 'gets JSON through an HTTP request' do
      VCR.use_cassette('get-menus') do

        sp = SinglePlatform.new(
          client_id: ENV['SP_CLIENT_ID'],
          secret:    ENV['SP_CLIENT_SECRET']
        )
      
        menus = sp.get_menus(location_id:'hakkasan-mayfair')

        expect(menus['data'][0]['id']).to eq 3808555

      end
    end
  end

end