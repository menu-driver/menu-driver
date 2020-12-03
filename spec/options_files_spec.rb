require 'spec_helper'
require 'menudriver/options-files'

describe "Options Files" do

  options_file_A =
    <<-ERB_A
    test-location:
      theme: standard
    ERB_A

  # A second web menu, using the data from the first location, different theme.
  options_file_B =
    <<-ERB_B
    test-location-B:
      location: test-location
      theme: child
    ERB_B

  context 'loading' do

    before(:each) do
      allow(File).to receive(:read).
        with('themes/standard.theme/options.yaml').
        and_return(options_file_A)
      allow(File).to receive(:read).
        with('themes/standard.theme/child.theme/options.yml').
        and_return(options_file_B)
      allow(Dir).to receive(:glob).with('themes/**/*.{yml,yaml}').
        and_return([
          'themes/standard.theme/options.yaml',
          'themes/standard.theme/child.theme/options.yml'])

      @options_files = MenuDriver::OptionsFiles.new
    end

    it 'recursively locates all options files in the themes folder' do
      expect(@options_files.data.size).to be 2
      expect(@options_files.menu_names). to include 'test-location'
      expect(@options_files.menu_names). to include 'test-location-B'
    end

    pending 'loads the options for each location' do
      error
    end

  end

end
