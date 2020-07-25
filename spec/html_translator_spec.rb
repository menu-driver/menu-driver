require 'spec_helper'
require_relative '../lib/single-platform'

describe "HTML translator" do

  before(:all) do
    @single_platform = SinglePlatform.new(
        client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
        secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
      )
  end

  context "generates menu html", :vcr do

    it 'returns HTML for a given location' do

      menus = @single_platform.generate_menus_html(location_id:'hakkasan-mayfair')

      pending('testing for templated HTML')
      fail

    end

  end

end