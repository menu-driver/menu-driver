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

      data = @single_platform.fetch_location_data_from_api(
        location_id:'hakkasan-mayfair')

      expect(data.menus.count).to eq 17
      expect(data.menus.first.name).to eq 'A la Carte'
      expect(data.menus.first.sections.count).to eq 11

    end

  end

end