class SinglePlatform::DynamoDB

  def connection

    options = {}
    # Use a local DynamoDB 'normally', unless running in an "AWS execution
    # environmnet" (Lambda) and not in SAM Local.
    options.merge!(endpoint: 'http://127.0.0.1:8000') unless ENV['AWS_EXECUTION_ENV']
    options[:endpoint] = 'http://dynamodb:8000' if ENV['AWS_SAM_LOCAL']

    $logger.debug "DynamoDB options: #{options.ai}"

    @connection ||= Aws::DynamoDB::Client.new(options)

  end

  def self.menus_table_name
    menus_table_name = ENV['MENUS_TABLE_NAME'] || 'MenusTable'
    $logger.debug "DynamoDB table name: #{menus_table_name}"
    menus_table_name
  end
  
  def purge_menus_cache
    begin
      response = connection.scan(
        table_name: self.class.menus_table_name)
      response.items.each do |item|
        item['id']
        @connection.delete_item(
          table_name: self.class.menus_table_name,
          key: { id: item['id'] }
        )
      end
    end

  end
  
  # Return cached menu data for this location from DynamoDB if it exists.
  # If not, then yield and let the block passed by the caller compute the
  # response.  And then cache that for next time.
  def cache_menus(location_id:, **args)

    cache_key = [location_id,args.to_s].join

    params = {
      table_name: self.class.menus_table_name,
      key: {
          id: cache_key
      }
    }
  
    response =
      begin
        $logger.debug "Preparing to get_item: #{params.ai}"
        connection.get_item(params)
      rescue Aws::DynamoDB::Errors::ServiceError => error
        $logger.error "Error finding menu for location_id: #{location_id} -- " +
          error.message
        nil
      end
    
    $logger.debug "DynamoDB responded."

    if response.nil? or response.item.nil?
      $logger.info  "Could not find cached menu data for location_id: #{location_id}"

      # Call the block passed by the caller to compute the data.
      data = yield
  
      $logger.info "Caching menu data for location_id: #{location_id}"
  
      # Cache that data in DynamoDB.
      begin
        params = {
          table_name: self.class.menus_table_name,
          item: {
            id: cache_key,
            # Don't include all of the data in the logs.
            data: '...'
          }
        }

        $logger.debug "Preparing to put_item: #{params.ai}"
        
        # Add the data.
        params[:item][:data] = data

        connection.put_item(params)
      rescue Aws::DynamoDB::Errors::ServiceError => error
        $logger.error 'Unable to add menu data: ' + error.message
      end

      return data
    end

    $logger.debug "Returning data."
        
    response.item.to_dot.data

  end

end