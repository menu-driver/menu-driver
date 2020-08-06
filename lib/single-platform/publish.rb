require 'addressable'

class SinglePlatform

  def publish_file(file, contents)
    s3 = Aws::S3::Resource.new
    bucket_name = [ENV['STACK'], ENV['DOMAIN']].join('.')
    $logger.info "Publishing file \"#{file}\" in bucket: #{bucket_name}"
    s3_object = s3.bucket(bucket_name).
      object(file)
    s3_object.put(body:gzip(contents),
      content_type: 'text/html',
      content_encoding: 'gzip')
    s3_object
  end

  def publish_menu_content(location_id:, **args)

    menus_html = generate_menus_html({:location_id => location_id}.merge(args))

    $logger.info "Storing HTML menu for location: #{location_id}"

    # TODO: Feature / parameter for overriding output file name.
    output_file_name = location_id + '/index.html'

    s3_object = publish_file(output_file_name, menus_html)
    
    # Identify asset files and publish those also.
    asset_files(location_id:location_id, **args).each do |asset_file|
      $logger.debug "Using asset file \"#{asset_file[:asset]}\" from path \"#{asset_file[:file_path]}\""
      publish_file(
        # Destinaton S3 object key.
        File.join(location_id, asset_file[:asset]),
        # Source bytes.
        File.read(asset_file[:file_path]))
    end

    bucket_name = [ENV['STACK'], ENV['DOMAIN']].join('.')
    public_url = 
      "http://#{bucket_name}.s3-website-us-east-1.amazonaws.com/#{location_id}"

    $logger.info "Public URL of generated menu: #{public_url}"

    s3_object

  end
  
  def asset_files(location_id:, **args)
    published_files = {}
    theme_folders = Theme.new(args[:theme]).folders

    asset_filenames = []
    theme_folders.each do |theme_folder|
      Dir.children(theme_folder).select{|child| !File.directory? File.join(theme_folder, child)}.
          reject{|file| file == 'index.html' }.each do |file|
        # Only publish the descendant for any given file.
        unless published_files[file]
          asset_filenames << {
            file_path: File.join(theme_folder, file),
            asset: file
          }
          published_files[file] = true
        end
      end
    end
    asset_filenames
  end

end

def gzip(data)
  sio = StringIO.new
  gz = Zlib::GzipWriter.new(sio)
  gz.write(data)
  gz.close
  sio.string
end
