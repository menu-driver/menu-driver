require 'aws-sdk-comprehend'

module MenuDriver

  class Data

    attr_accessor :location_data, :category, :menu

    @@default_category_name = 'General'

    def initialize params = {}
      params.each { |key, value| send "#{key}=", value }
      process
    end

    # Transform the menus, to change or add anything necessary.
    def process
      detectCategories
      detectLanguage
    end

    # Basic data access functions.

    def location_name
      location_data.location.name.gsub(/\s*test\s*location\s*/i,'')
    end

    def location_description
      location_data.location.description
    end

    def location_website
      location_data.location.website
    end

    def menus
      menus = location_data.menus
      if self.menu
        menus = menus.select do |this_menu|
          self.menu.downcase.include?(this_menu.name.downcase) ||
          self.menu.downcase.include?(this_menu.id.to_s)
        end
      end
      menus = menus.select{|menu| menu.category.eql? category } if category
      menus
    end

    def categories
      return [] unless menus.any?{|menu| menu[:category] }
      categories = menus.map{|menu| menu[:category] || @@default_category_name}.uniq
      categories = [category] if category
      categories
    end

    def named_categories
      return [] unless menus.any?{|menu| menu[:category] }
      categories = menus.select{|menu|
        !menu[:category].eql? @@default_category_name}.map{|menu|
          menu[:category]}.uniq
      categories = [category] if category
      categories
    end

    # Utility functions.

    def detectCategories
      location_data.menus.each do |menu|
        if(match = /(^[^\-]+)\s+\-\s+(.+$)/.match(menu.name))
          menu.category = match[1]
          menu.name = match[2]
        else
          menu.category = @@default_category_name
        end
      end
    end

    def detectLanguage
      client = Aws::Comprehend::Client.new()

      self.location_data.menus =
        menus.map do |menu|

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

    def main_image
      if (main_image =
        location_data.photos.select{|photo| photo.main_image }.first)
        main_image.url
      else
        nil
      end
    end

  end

end
