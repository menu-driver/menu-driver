require 'openssl'
require 'base64'
require 'erb'
require 'httparty'
require 'awesome_print'

class SinglePlatform
  
  def initialize(client_id:, secret:)
    @client_id = client_id
    @secret = secret
  end
  
  def get_menus(location_id:)
    response = HTTParty.get(
      build_signed_url(uri_path: "/locations/#{location_id}/menus/",
      format: 'short')
    )
    JSON.parse(response.body)
  end

  def build_signed_url(uri_path:, **args)
    args.update({"client" => @client_id})
    path =
      uri_path + "?" +
      args.collect{|k,v| "#{k}=#{v}"}.inject{|initial,cur| initial + "&" + cur}

    digest =
      Base64.encode64(
        OpenSSL::HMAC.digest('sha1', @secret, path)).strip
    
    'https://publishing-api.singleplatform.com' +
    "#{path}&signature=#{ERB::Util.url_encode digest}"
  end

end