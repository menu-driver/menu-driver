class SinglePlatform

  def menus(location_id:, **args)

    # Construct a signed URL and send an HTTP request to the API.
    api_url = build_signed_url(
      uri_path:"/locations/#{location_id}/menus/",
      **args)

    response = HTTParty.get(api_url)

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    JSON.parse(response.body).to_dot.data

  end

end