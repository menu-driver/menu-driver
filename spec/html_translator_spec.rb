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
      expect(@menus_html).to have_title('Hakkasan Mayfair Menus')
    end

    it 'creates HTML element for each menu', type: :feature do
      expect(@menus_html).to have_css('.menu', minimum:3)
    end

    it 'includes the menu ID as the HTML ID for a menu', type: :feature do
      expect(@menus_html).to have_selector('.menu#menu-3808555')
    end

    it 'includes the menu name as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .name', text: 'A la Carte')
    end

    it 'includes the menu section ID as the HTML ID for a menu section', type: :feature do
      expect(@menus_html).to have_selector('.menu .section#section-33726089')
    end

    it 'includes the menu section name as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .name', text: 'Red')
    end

    it 'includes the menu section item as an HTML element', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .item', text: '2005 Domaine de la Romanée-Conti')
    end

    it 'includes the menu section item ID as the HTML ID for a menu section item', type: :feature do
      expect(@menus_html).to have_selector('.menu .section .item#item-189551749')
    end

  end

  context 'parameters', :vcr do

    let(:alternate_template) do
      <<-ERB
      <html>
        <head>
          <title>ALTERNATE TEMPLATE</title>
        </head>
        <body>
          <div id="passthrough"><%= args[:passthrough] %></div>
        </body>
      </html>
ERB
    end

    before(:each) do
      allow(File).to receive(:exist?).with(anything)
      allow(File).to receive(:exist?).with('themes/alternate.theme/index.html').and_return(true)
      allow(File).to receive(:read).with('themes/alternate.theme/index.html').and_return(alternate_template)
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/standard.theme/",
          "themes/alternate.theme/"])
    end

    it 'passes parameters into the template.', type: :feature do

      menus_html =
        @single_platform.generate_menus_html(
          location_id:   'hakkasan-mayfair',
          theme:         'alternate',
          'passthrough': 'SIERRA'
        )

      expect(menus_html).to have_selector('#passthrough', text:'SIERRA')
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

          <% for menu in data.menus %>
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
      allow(File).to receive(:read).with('themes/standard.theme/index.html').and_return(alternate_template)

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

  context 'supports SCSS styles', :vcr do

    let(:alternate_template) do
      <<-ERB
<html>
  <head>
    <title><%= location_id %></title>
    <meta charset="UTF-8">
    <style>
<%= SassC::Engine.new(File.read('themes/standard.theme/styles.scss')).render %></style>
  </head>
  <body>
    The body is not the point in this one.
  </body>
</html>
ERB
    end

    let(:alternate_scss) do
      <<-SCSS
.menu {
  .section {
    .item {
      .name {
        color: red;
      }
    }
  }
}
SCSS
    end

    before(:each) do
      allow(File).to receive(:read).with('themes/standard.theme/index.html').and_return(alternate_template)
      expect(File).to receive(:read).with('themes/standard.theme/styles.scss').and_return(alternate_scss)

      @location_id = 'hakkasan-mayfair'
      @menus_html =
        @single_platform.generate_menus_html(location_id:@location_id)
    end

    it 'includes CSS generated from include SCSS in the output HTML', type: :feature do
      expect(@menus_html).to include(".menu .section .item .name {\n  color: red; }")
    end

  end

  context 'category parameter', :vcr do

    it 'filters out all but one category from the generated menu.', type: :feature do

      location_id = 'hakkasan-mayfair'
      @menus_html =
        @single_platform.generate_menus_html(
          location_id:location_id,
          category: 'Drinks')

      expect(@menus_html).to have_selector('.menu .name', text: 'Cocktails')
      expect(@menus_html).not_to have_selector('.menu .name', text: 'A la Carte')

    end

  end

end
