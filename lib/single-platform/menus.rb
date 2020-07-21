class SinglePlatform

  def menus(location_id:, **args)

    # Construct a signed URL and send an HTTP request to the API.
    response = HTTParty.get(
      build_signed_url(uri_path:"/locations/#{location_id}/menus/", **args)
    )

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    JSON.parse(response.body).to_dot.data

  end

end