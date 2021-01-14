require 'open-uri'

require 'menudriver/data'

# These are available to the ERB template code.
require 'nokogiri'
require 'sassc'
require 'htmlcompressor'

class SinglePlatform

  def generate_menus_html(location_id:, **args)

    $logger.info "Generating HTML menu file for location: #{location_id}"
    $logger.debug "Current working directory: #{Dir.pwd}"

    raw_data = fetch_location_data_from_api(location_id:location_id, **args)

    # Wrap the data in functionality.  For things like
    # detecting the dominant language.
    data = MenuDriver::Data.new(
      args.select{|arg| [:category, :menu].include? arg }.
      merge(location_data: raw_data))

    # Get the HTML (ERB) template.
    theme = Theme.new(args[:theme])
    template = theme.file('index.html')

    # Render output HTML.
    renderer = ERB.new(template, nil, '-')
    html = renderer.result(binding)

    # Perform short-code substitutions.
    file = theme.file('codes.yml')
    if file && (codes = YAML.load(file))
      codes.each do |code|
        html.gsub! /#{code[0]}/, code[1]
      end
    end

    # Compress it.
    compressor = HtmlCompressor::Compressor.new
    compressor.compress(html)

  end

end
