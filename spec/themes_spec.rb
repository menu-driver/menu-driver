require 'spec_helper'
require_relative '../lib/single-platform'

describe "support for multiple themes" do

  before(:all) do
    @single_platform = SinglePlatform.new(
        client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
        secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
      )
    ENV['THEME'] = nil
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
      allow(File).to receive(:exist?).with(anything)
      allow(File).to receive(:exist?).with('themes/alternate.theme/index.html').and_return(true)
      allow(File).to receive(:read).with('themes/alternate.theme/index.html').and_return(alternate_template)
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/standard.theme/",
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

    it 'uses a different theme template when a theme environment variable is provided.', type: :feature do

      ENV['THEME'] = 'alternate'

      menus_html =
        @single_platform.generate_menus_html(
          location_id: 'hakkasan-mayfair'
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

    it 'uses a child theme template when a theme parameter is provided.', type: :feature do

      # There is a child theme.
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/standard.theme/",
          "themes/standard.theme/child.theme/"])

      # The child theme has an index.html file.
      allow(File).to receive(:exist?).with(anything)
      allow(File).to receive(:exist?).with('themes/standard.theme/child.theme/index.html').and_return(true)
      allow(File).to receive(:read).with('themes/standard.theme/child.theme/index.html').and_return(alternate_template)

      menus_html =
        @single_platform.generate_menus_html(
          location_id: 'hakkasan-mayfair',
          theme:       'child'
        )

      expect(menus_html).to have_title('CHILD TEMPLATE')
    end

    it 'loads a file from a parent theme if the file is missing from the current theme', type: :feature do

      # There is a child theme.  But there is no index.html file!
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/standard.theme/",
          "themes/standard.theme/child.theme/"])

      menus_html =
        @single_platform.generate_menus_html(
          location_id: 'hakkasan-mayfair',
          theme:       'child'
        )

      expect(menus_html).to have_title('hakkasan-mayfair')

    end

    it 'copies all asset files from the parent theme', type: feature do

      # There is a child theme.
      allow(Dir).to receive(:glob).with('themes/**/*/').
        and_return([
          "themes/standard.theme/",
          "themes/standard.theme/child.theme/"])
      # It has no files!
      allow(Dir).to receive(:children).with('themes/standard.theme/child.theme').
        and_return([])
      allow(Dir).to receive(:children).with('themes/standard.theme').
        and_return(['child.theme', 'scripts.js'])
      allow(File).to receive(:directory?).with('themes/standard.theme/child.theme').and_return(true)
      allow(File).to receive(:directory?).with('themes/standard.theme/scripts.js').and_return(false)

      single_platform = SinglePlatform.new(
            client_id: ENV['SINGLE_PLATFORM_CLIENT_ID'],
            secret:    ENV['SINGLE_PLATFORM_CLIENT_SECRET']
          )
      
      object = Aws::S3::Resource.new.bucket('menu-driver-test').object('example')
      allow(single_platform).to receive(:publish_file).with(anything, anything).and_return(object)
      expect(single_platform).to receive(:publish_file).with('hakkasan-mayfair/scripts.js', anything).and_return(object)
          
      single_platform.publish_menu_content(
        location_id: 'hakkasan-mayfair',
        theme:       'child')

    end

  end

end