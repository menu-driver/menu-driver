module MenuDriver
  
  class Data
    
    attr_accessor :location, :menus_data
  
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

    
    
  end
  
end