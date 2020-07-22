require 'aws-sdk'

class SinglePlatform::DynamoDB

  def initialize
    options = {}
    options.merge!(endpoint: 'http://127.0.0.1:8000') unless (ENV['AWS_EXECUTION_ENV'] && !ENV['AWS_SAM_LOCAL'])
    @connection = Aws::DynamoDB::Client.new(options)
  end
  
  def connection
    @connection
  end

  def self.menus_table_name
    ENV['MENUS_TABLE_NAME'] || 'MenusTable'
  end
  
  def purge_menus_cache
    begin
      response = @connection.scan(
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

end