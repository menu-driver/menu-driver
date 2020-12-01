require 'spec_helper'
require_relative '../lambda'

describe "publish" do

  context 'asset files', :vcr do

    it 'uploads to S3', type: feature do

      expect_any_instance_of(Aws::S3::Bucket).
        to receive(:object).with('hakkasan-mayfair/index.html').and_return(
          Aws::S3::Resource.new.bucket('test.menus.hakkasangroup.com').
          object('hakkasan-mayfair/index.html'))

      SinglePlatform.new(
            client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
            secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
          ).publish_file(
            'hakkasan-mayfair/index.html',
            'lorem ipsum')

    end

  end

  context "main HTML menu file", :vcr do

    it 'upload to the index.html file for the location' do

      s3_object = SinglePlatform.new(
            client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
            secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
          ).publish_menu_content(location_id:'hakkasan-mayfair')

      expect(s3_object.key).to eq('hakkasan-mayfair/index.html')

    end

  end

  context 'assets', :vcr do

    it 'copies all asset files from the theme', type: feature do

      single_platform = SinglePlatform.new(
            client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
            secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
          )

      object = Aws::S3::Resource.new.bucket('menu-driver-test').object('example')
      allow(single_platform).to receive(:publish_file).with(anything, anything).and_return(object)
      expect(single_platform).to receive(:publish_file).with('hakkasan-mayfair/scripts.js', anything).and_return(object)

      single_platform.publish_menu_content(location_id:'hakkasan-mayfair')

    end

  end

end
