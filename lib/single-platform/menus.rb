class SinglePlatform

  def fetch_menus_data_from_api(location_id:, **args)
    
    $logger.info "Fetching menu data from Single Platform API."
    
    # Construct a signed URL and send an HTTP request to the API.
    api_url = build_signed_url(
      uri_path:"/locations/#{location_id}/menus/",
      **args)

    $logger.debug "Single Platform API URL: #{api_url}"

    response = HTTParty.get(api_url)
    
    $logger.debug "Single Platform API response: #{response.ai}"

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    JSON.parse(response.body).to_dot.data

  end
  
  def generate_menus_html(location_id:, **args)
    
    $logger.info "Generating HTML menu file for location: #{location_id}"

    menus_data = fetch_menus_data_from_api(location_id:location_id, **args)

    '<html>HTML menu!</html>'

  end
  
end