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

      expect(data.menus.count).to eq 18
      expect(data.menus.first.name).to eq 'Signature Menus - Shou'
      expect(data.menus.first.sections.count).to eq 5

    end

  end

  context "caches menu data", :vcr do

    it 'stores the JSON data after getting it from the API' do

      allow(File).to receive(:write).with('cache/hakkasan-mayfair.json', anything)

      data = @single_platform.fetch_location_data_from_api(
        location_id:'hakkasan-mayfair', 'cache':true)

      expect(data.menus.count).to eq 18
      expect(data.menus.first.name).to eq 'Signature Menus - Shou'
      expect(data.menus.first.sections.count).to eq 5

    end

    let :cached_data do
      <<-DATA
{"menus":[{"id":1,"menu_type":"Menu","location_id":"hakkasan-mayfair","name":"Test"}]}
DATA
    end

    let(:empty_response) { "{}" }

    it 'uses cached data instead of making an API request' do

      expect(File).to receive(:exist?).with('cache/hakkasan-mayfair.json').and_return(true)
      expect(File).to receive(:read).with('cache/hakkasan-mayfair.json').and_return(cached_data)
      allow(File).to receive(:write).with('cache/hakkasan-mayfair.json', anything)

      allow(HTTParty).to receive(:get).and_return(Struct.new(:code, :body).new(200, empty_response))

      data = @single_platform.fetch_location_data_from_api(
        location_id:'hakkasan-mayfair', 'cache':true)

      expect(data.menus.count).to eq 1
      expect(data.menus.first.name).to eq 'Test'
      expect(HTTParty).not_to have_received(:get)

    end

  end

  context "menu data from file system", :vcr do

    let :custom_data do
      <<-DATA
{"menus":[{"id":1,"menu_type":"Menu","location_id":"hakkasan-mayfair","name":"Custom"}]}
DATA
    end

    let(:empty_response) { "{}" }

    it 'uses custom data instead of making an API request' do

      expect(File).to receive(:exist?).with('data/hakkasan-mayfair.json').and_return(true)
      expect(File).to receive(:read).with('data/hakkasan-mayfair.json').and_return(custom_data)
      allow(File).to receive(:write).with('data/hakkasan-mayfair.json', anything)

      allow(HTTParty).to receive(:get).and_return(Struct.new(:code, :body).new(200, empty_response))

      data = @single_platform.fetch_location_data_from_api(
        location_id:'hakkasan-mayfair', 'data_file':'data/hakkasan-mayfair.json')

      expect(data.menus.count).to eq 1
      expect(data.menus.first.name).to eq 'Custom'
      expect(HTTParty).not_to have_received(:get)

    end

  end

end
