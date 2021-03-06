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
        $logger.debug "Found options file: #{file}"
        entries = YAML.load(File.read(file))
        next unless entries
        entries.each do |name|
          self.data.push(name)
        end
      end
    end

    def menu_names
      self.data.map{|entry| entry.first }
    end

    def menu_options(menu_name)
      entry = self.data.select{|entry| entry[0].eql? menu_name}.first
      return nil unless entry
      entry[1]
    end

  end

end
