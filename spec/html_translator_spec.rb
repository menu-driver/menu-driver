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

    let(:alternate_template) do
      <<-ERB
      <html>
        <head>
          <title><%= location_id %></title>
        </head>
        <body>
        
          <div class="from-template">From the template.</div>

          <% for menu in menus %>
            <div class="menu" id="<%= menu.id %>">
              <%= menu.name %>
            </div>
          <% end %>
          
          <%= Nokogiri::HTML(open("https://hakkasangroup.com/")).css('footer').to_s %>

        </body>
      </html>
ERB
    end

    before(:each) do
      allow(File).to receive(:read).with('themes/default/menus.html').and_return(alternate_template)

      @location_id = 'hakkasan-mayfair'
      @menus_html =
        @single_platform.generate_menus_html(location_id:@location_id)
    end

    it 'includes stuff from the template ', type: :feature do
      expect(@menus_html).to have_title(@location_id)
      expect(@menus_html).to have_selector('.from-template', text: 'From the template.')
    end

    it 'includes stuff from the data', type: :feature do
      expect(@menus_html).to have_selector('.menu#3808555')
    end

    it 'includes stuff from the third-party site', type: :feature do
      expect(@menus_html).to have_selector('footer')
      expect(@menus_html).to have_selector('section.footer-hakkasan-logo')
    end

  end

end