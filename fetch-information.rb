require 'dotenv/load'

require_relative 'lib/single-platform'

sp = SinglePlatform.new(
  client_id: ENV['SP_CLIENT_ID'],
  secret:    ENV['SP_CLIENT_SECRET']
)

sp.get_menus(location_id:'herringbone-santa-monica')