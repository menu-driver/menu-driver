module SamParameterEnvironment

# Get environment variables from the samconfig.toml file.
# Sort of like using dotenv, but the environment variables come from the
# 'parameter_overrides' setting in the SAM configuration file instead of from
# a .env file.
  def self.load
    require 'toml'
    TOML.load_file('samconfig.toml')['default']['deploy']['parameters'
      ]['parameter_overrides'].
      split(' ').each do |variable|
        parts = variable.split '='
        ENV[parts[0].gsub(/(?<!^)[A-Z]/) do "_#$&" end.upcase] = parts[1]
      end
  end

end