class SinglePlatform

  def generate_html_menus(location_id:, **args)

    menus_html = generate_menus_html({:location_id => location_id}.merge(args))

    $logger.info "Storing HTML menu for location: #{location_id}"

    # Build an output file name that includes any URL query parameters.
    output_file_name = location_id

    if args.count > 0
      uri = Addressable::URI.new
      uri.query_values = args
      output_file_name = [output_file_name, uri.query].join('?')
    end

    s3 = Aws::S3::Resource.new
    s3_object = s3.bucket('menu-driver-'+ENV['STACK_NAME']).
      object(output_file_name)
    s3_object.put(body:gzip(menus_html),
      content_type: 'text/html',
      content_encoding: 'gzip')

    $logger.info "Public URL of generated menu: #{s3_object.public_url}"

    s3_object

  end

end

def gzip(data)
  sio = StringIO.new
  gz = Zlib::GzipWriter.new(sio)
  gz.write(data)
  gz.close
  sio.string
end
