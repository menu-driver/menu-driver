require 'open-uri'

require 'menudriver/data'

# These are available to the ERB template code.
require 'nokogiri'
require 'sassc'
require 'htmlcompressor'

class SinglePlatform

  def generate_menus_html(location_id:, **args)

    $logger.info "Generating HTML menu file for location: #{location_id}"

    raw_data = fetch_location_data_from_api(location_id:location_id, **args)

    # Wrap the data in functionality.  For things like
    # detecting the dominant language.
    data = MenuDriver::Data.new(location_data: raw_data)

    # Get the HTML (ERB) template.
    template = Theme.new(args[:theme]).file('index.html')

    # Render output HTML.
    renderer = ERB.new(template, nil, '-')
    html = renderer.result(binding)
    
    # Compress it.
    compressor = HtmlCompressor::Compressor.new
    compressor.compress(html)    

  end

end