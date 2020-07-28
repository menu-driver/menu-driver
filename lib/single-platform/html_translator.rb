require 'open-uri'

# These are available to the ERB template code.
require 'nokogiri'
require 'sassc'

class SinglePlatform

  def generate_menus_html(location_id:, **args)

    $logger.info "Generating HTML menu file for location: #{location_id}"

    menus = fetch_menus_data_from_api(location_id:location_id, **args)

    # Select the theme name.
    theme_name = args[:theme] || 'default'

    # Get the HTML (ERB) template.
    template = File.read("themes/#{theme_name}.theme/menus.html")

    renderer = ERB.new(template)

    renderer.result(binding)

  end

end