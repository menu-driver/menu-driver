require 'aws-sdk-comprehend'

module MenuDriver
  
  class Data
    
    attr_accessor :location, :menus_data
  
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
      process
    end
    
    # Transform the menus, to change or add anything necessary.
    def process
      detectCategories
      detectLanguage
    end

    def detectCategories
      self.menus_data.each do |menu|
        if(match = /(^[^\-]+)\-([^\-]+$)/.match(menu.name))
          menu.category = match[1]
          menu.name = match[2]
        end
      end
    end
 
    def detectLanguage
      client = Aws::Comprehend::Client.new()
      
      self.menus_data = 
        self.menus_data.map do |menu|
        
          # Detect the language.
          menu_text =
            [
              menu.name,
              menu.description,
              menu.sections.map do |section|
                [
                  section.name,
                  section.description,
                  section.items.map do |item|
                    [
                      item.name,
                      item.description
                    ].join(' ')
                  end
                ].join(' ')
              end.join(' ')
            ].join(' ')
          resp = client.detect_dominant_language({text: menu_text[0..2500]})
  
          menu.merge({
            'language' => resp.languages.first.language_code
          })
        end
    end

    def menus
      menus_data
    end

    def categories
      menus_data.map{|menu| menu[:category] || 'Other'}.uniq
    end

  end

end