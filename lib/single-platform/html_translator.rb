class SinglePlatform

  def generate_menus_html(location_id:, **args)

    $logger.info "Generating HTML menu file for location: #{location_id}"

    menus = fetch_menus_data_from_api(location_id:location_id, **args)

    # Get the HTML (ERB) template.
    template = File.read('themes/default/menus.html')

    renderer = ERB.new(template)

    renderer.result(binding)

  end

end