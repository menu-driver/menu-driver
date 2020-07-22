require 'spec_helper'
require_relative '../lib/single-platform'

describe "DynamoDB caching" do

  # Delete all entries in the menu data.
  before(:each) do
    SinglePlatform::DynamoDB.new.purge_menus_cache
  end

  context "caches menu data", :vcr do

    it 'issues an HTTP request to the API when there is no cached menu data' do

      single_platform = SinglePlatform.new(
        client_id: ENV['SP_CLIENT_ID'],
        secret:    ENV['SP_CLIENT_SECRET']
      )

      expect(single_platform).to receive(:fetch_menus_from_api).once

      single_platform.menus(location_id:'hakkasan-mayfair')

    end

    it 'does not issue a new HTTP request to the API when menu data is already cached' do

      single_platform = SinglePlatform.new(
        client_id: ENV['SP_CLIENT_ID'],
        secret:    ENV['SP_CLIENT_SECRET']
      )

      expect(single_platform).to receive(:fetch_menus_from_api).once

      # It should call the Single Platform API the first time.
      single_platform.menus(location_id:'hakkasan-mayfair')

      # It should not call the Single Platform API the second time.
      single_platform.menus(location_id:'hakkasan-mayfair')

    end
    
    it 'does not cause a failure if the DynamoDB request fails.' do

      single_platform = SinglePlatform.new(
        client_id: ENV['SP_CLIENT_ID'],
        secret:    ENV['SP_CLIENT_SECRET']
      )

      expect_any_instance_of(Aws::DynamoDB::Client).
        to receive(:get_item).
          and_raise(Aws::DynamoDB::Errors::ServiceError.new({}, 'ERROR!'))

      # It should call the Single Platform API the first time.
      menus = single_platform.menus(location_id:'hakkasan-mayfair')

      expect(menus.count).to eq 17
      expect(menus.first.name).to eq 'A la Carte'
      expect(menus.first.sections.count).to eq 11

    end

    it 'does not cause a failure if caching data in DynamoDB fails.' do

      single_platform = SinglePlatform.new(
        client_id: ENV['SP_CLIENT_ID'],
        secret:    ENV['SP_CLIENT_SECRET']
      )

      expect_any_instance_of(Aws::DynamoDB::Client).
        to receive(:put_item).
          and_raise(Aws::DynamoDB::Errors::ServiceError.new({}, 'ERROR!'))

      # It should call the Single Platform API the first time.
      menus = single_platform.menus(location_id:'hakkasan-mayfair')

      expect(menus.count).to eq 17
      expect(menus.first.name).to eq 'A la Carte'
      expect(menus.first.sections.count).to eq 11

    end

  end

end