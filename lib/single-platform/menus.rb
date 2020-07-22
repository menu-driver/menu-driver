class SinglePlatform

  def menus(location_id:, **args)

    cache_menus_in_dynamodb(location_id:location_id, **args) do
      fetch_menus_from_api(location_id:location_id, **args)
    end

  end
  
  def fetch_menus_from_api(location_id:, **args)
    # Construct a signed URL and send an HTTP request to the API.
    api_url = build_signed_url(
      uri_path:"/locations/#{location_id}/menus/",
      **args)

    response = HTTParty.get(api_url)

    # Return the 'data' from the JSON response body,
    # set up with hash_dot for easy access.
    JSON.parse(response.body).to_dot.data
  end
  
  # Return cached menu data for this location from DynamoDB if it exists.
  # If not, then yield and let the block passed by the caller compute the
  # response.  And then cache that for next time.
  def cache_menus_in_dynamodb(location_id:, **args)

    cache_key = [location_id,args.to_s].join

    params = {
      table_name: 'MenusTable',
      key: {
          id: cache_key
      }
    }
  
    response =
      begin
        dynamodb.get_item(params)
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        # puts "Error finding menu for location_id: #{location_id}"
        # puts error.message
      end

    if response.nil? or response.item.nil?
      # puts "Could not find menu for location_id: #{location_id}"

      # Call the block passed by the caller to compute the data.
      data = yield
  
      # Cache that data in DynamoDB.
      begin
        params = {
          table_name: 'MenusTable',
          item: {
            id: cache_key,
            data: data
          }
        }
        dynamodb.put_item(params)
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts 'Unable to add menu data:'
        puts error.message
      end

      return data
    end

    response.item.to_dot.data

  end

end