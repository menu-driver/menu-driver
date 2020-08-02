require 'addressable'

class SinglePlatform

  def publish_file(file, contents)
    s3 = Aws::S3::Resource.new
    s3_object = s3.bucket('menu-driver-' + ENV['STACK_NAME']).
      object(file)
    s3_object.put(body:gzip(contents),
      content_type: 'text/html',
      content_encoding: 'gzip')
    s3_object
  end

  def publish_menu_content(location_id:, **args)

    menus_html = generate_menus_html({:location_id => location_id}.merge(args))

    $logger.info "Storing HTML menu for location: #{location_id}"

    # Build an output file name that includes any URL query parameters.
    output_file_name = location_id + '/index.html'

    if args.count > 0
      uri = Addressable::URI.new
      uri.query_values = args
      output_file_name = [output_file_name, uri.query].join('?')
    end

    s3_object = publish_file(output_file_name, menus_html)
    
    # Identify asset files and publish those also.
    asset_filenames(location_id:location_id, **args).each do |asset_filename|
      publish_file(
        File.join(location_id, asset_filename),
        File.read(File.join(Theme.new(args[:theme]).folder, asset_filename)))
    end

    $logger.info "Public URL of generated menu: #{s3_object.public_url}"

    s3_object

  end
  
  def asset_filenames(location_id:, **args)
    Dir.children(theme_folder = Theme.new(args[:theme]).folder).
      select{|child| !File.directory? File.join(theme_folder, child)}.
        reject{|file| file == 'index.html' }
  end

end

def gzip(data)
  sio = StringIO.new
  gz = Zlib::GzipWriter.new(sio)
  gz.write(data)
  gz.close
  sio.string
end
