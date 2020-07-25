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

    it 'relays menu data in JSON format' do

      response = 
        menus_data(
          event:JSON.parse(
            File.read('spec/lambda_events/location_id_hakkasan_mayfair.json')),
          context:{})
          
      expect(response[:statusCode]).to eq 200

      menus = JSON.parse(response[:body]).to_dot.message

      expect(menus.count).to eq 17
      expect(menus.first.name).to eq 'A la Carte'
      expect(menus.first.sections.count).to eq 11

    end

  end

end