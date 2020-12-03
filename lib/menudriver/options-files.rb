require 'yaml'

module MenuDriver

  class OptionsFiles

    attr_accessor :data

    def initialize params = {}
      self.data = []
      load_options_files
    end

    def load_options_files
      Dir.glob('themes/**/*.{yml,yaml}').each do |file|
        YAML.load(File.read(file)).each do |name|
          self.data.push(name)
        end
      end
    end

    def menu_names
      self.data.map{|entry| entry.first }
    end

    def menu_options(menu_name)
      self.data.select{|entry| entry[0].eql? menu_name}.first[1]
    end

  end

end
