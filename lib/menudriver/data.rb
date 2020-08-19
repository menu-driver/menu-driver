require 'aws-sdk-comprehend'

module MenuDriver
  
  class Data
    
    attr_accessor :location, :menus_data
  
    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
    end

    # Transform the menus, to change or add anything necessary.
    def menus
      client = Aws::Comprehend::Client.new()
      
      menus_data.map do |menu|
      
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

  end


  class Menu

    # client = Aws::Comprehend::Client.new()
    # resp = client.detect_dominant_language({text:""})

  end
  
end