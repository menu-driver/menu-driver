require 'spec_helper'
require_relative '../lib/single-platform'

describe "HTML translator" do

  before(:all) do
    @single_platform = SinglePlatform.new(
        client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
        secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
      )
  end

  context 'generates menu HTML', :vcr do

    before(:each) do
      @location_id = 'hakkasan-mayfair'
      @menus_html =
        @single_platform.generate_menus_html(location_id:@location_id)
      # puts "HTML: #{@menus_html}"
    end

    it 'has the location ID in the HTML page title', type: :feature do
      expect(@menus_html).to have_title(@location_id)
    end

    it 'creates HTML elements each menu', type: :feature do
      expect(@menus_html).to have_css('.menu', count:17)
    end

    it 'includes the menu ID as the HTML ID for a menu', type: :feature do
      expect(@menus_html).to have_selector('.menu#3808555')
    end

    it 'includes the menu name as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .name', text: 'A la Carte')
    end
    
    it 'includes the menu section ID as the HTML ID for a menu section', type: :feature do
      expect(@menus_html).to have_selector('.menu .section#33726089')
    end

    it 'includes the menu section name as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .name', text: 'Red')
    end

    it 'includes the menu section item as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .item', text: '2005 Domaine de la Romanée-Conti')
    end

    it 'includes the menu section item ID as the HTML ID for a menu section item', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .item#189551749')
    end

  end

  context 'supports multiple template themes' do
  
    pending 'itemizes a list of existing themes' do
      fail
    end
      
  end

  context 'proxies third-party HTML content', :vcr do
    
    pending 'includes HTML element from another site in generated HTML' do
      fail
    end

  end

end