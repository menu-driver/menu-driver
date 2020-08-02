require 'spec_helper'
require_relative '../lib/single-platform'

describe "support for multiple themes" do

  before(:all) do
    @single_platform = SinglePlatform.new(
        client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
        secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
      )
  end

  context 'switcher', :vcr do

    let(:alternate_template) do
      <<-ERB
      <html>
        <head>
          <title>ALTERNATE TEMPLATE</title>
        </head>
        <body>
          ALTERNATE TEMPLATE
        </body>
      </html>
ERB
    end

    before(:each) do
      allow(File).to receive(:read).with('themes/alternate.theme/index.html').and_return(alternate_template)
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/default.theme/",
          "themes/alternate.theme/"])
    end

    it 'uses a different theme template when a theme parameter is provided.', type: :feature do

      menus_html =
        @single_platform.generate_menus_html(
          location_id: 'hakkasan-mayfair',
          theme:       'alternate'
        )

      expect(menus_html).to have_title('ALTERNATE TEMPLATE')
    end

  end
  
  context 'inheritance', :vcr do
    
    let(:alternate_template) do
      <<-ERB
      <html>
        <head>
          <title>CHILD TEMPLATE</title>
        </head>
        <body>
          CHILD TEMPLATE
        </body>
      </html>
ERB
    end

    before(:each) do
      allow(File).to receive(:read).with('themes/default.theme/child.theme/index.html').and_return(alternate_template)
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/default.theme/",
          "themes/default.theme/child.theme/"])
    end

    it 'uses a child theme template when a theme parameter is provided.', type: :feature do

      menus_html =
        @single_platform.generate_menus_html(
          location_id: 'hakkasan-mayfair',
          theme:       'child'
        )

      expect(menus_html).to have_title('CHILD TEMPLATE')
    end

    pending 'loads a file from a parent theme if the file is missing from the current theme', type: :feature do

      fail

    end

    pending 'copies all asset files from the parent theme', type: feature do
      
      fail
      
    end

  end

end