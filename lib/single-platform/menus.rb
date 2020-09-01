require 'erb'

class SinglePlatform

  def fetch_location_data_from_api(location_id:, **args)

    $logger.info "Fetching menu data from Single Platform API."

    cache_folder_name = 'cache'
    cache_file_name = File.join(cache_folder_name, location_id) + '.json'

    raw_json =
      if args[:cache]
        if File.exist? cache_file_name
          $logger.info "Found cached data at: #{cache_file_name}"
          File.read cache_file_name
        end
      elsif args[:data_file]
        if File.exist? args[:data_file]
          $logger.info "Using data at: #{args[:data_file]}"
          File.read args[:data_file]
        end
      end

    unless raw_json

      # Construct a signed URL and send an HTTP request to the API.
      api_url = build_signed_url(
        uri_path:"/locations/#{location_id}/all/",
        **args)

      $logger.debug "Single Platform API URL: #{api_url}"

      response = HTTParty.get(api_url)

      unless response.code.eql? 200
        raise response.body
      end

      raw_json = JSON.parse(response.body).to_dot.data.to_json

    end

    parsed_data = JSON.parse(raw_json).to_dot

    # Store the data?
    if args[:cache]
      Dir.mkdir cache_folder_name unless Dir.exist? cache_folder_name
      File.write(cache_file_name, parsed_data.to_json)
    end

    # $logger.debug "Single Platform API response: #{response.ai}"
    # $logger.debug "Single Platform raw data: #{response.body}"

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    parsed_data

  end

end
