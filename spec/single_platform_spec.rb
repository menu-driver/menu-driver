require 'spec_helper'
require_relative '../lib/single-platform'

describe "Single Platform" do

  before(:all) do
    @single_platform = SinglePlatform.new(
        client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
        secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
      )
  end

  context "gets menu data", :vcr do

    it 'gets JSON through an HTTP request' do

      menus = @single_platform.fetch_menus_from_api(
        location_id:'hakkasan-mayfair')

      expect(menus.count).to eq 17
      expect(menus.first.name).to eq 'A la Carte'
      expect(menus.first.sections.count).to eq 11

    end

    it 'gets JSON for the "short" format' do

      menus = @single_platform.fetch_menus_from_api(
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