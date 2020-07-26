require 'erb'

class SinglePlatform

  def fetch_menus_data_from_api(location_id:, **args)
    
    $logger.info "Fetching menu data from Single Platform API."
    
    # Construct a signed URL and send an HTTP request to the API.
    api_url = build_signed_url(
      uri_path:"/locations/#{location_id}/menus/",
      **args)

    $logger.debug "Single Platform API URL: #{api_url}"

    response = HTTParty.get(api_url)
    
    # $logger.debug "Single Platform API response: #{response.ai}"
    # $logger.debug "Single Platform raw data: #{response.body}"

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    JSON.parse(response.body).to_dot.data

  end

end