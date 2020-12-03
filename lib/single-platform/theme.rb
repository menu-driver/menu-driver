class SinglePlatform::Theme

  def initialize(theme)
    @theme_name =
      # Select the theme name.
      theme + '.theme' || ENV['THEME'] || 'standard.theme'
  end

  def folder
    Dir.glob('themes/**/*/').select{|folder| folder =~ /\.theme\/$/}.
      select do |folder|
        /([^\.\/]+)\.theme\/$/.match(folder)[0].include? @theme_name
      end.first
  end

  # Recursive method that returns the last folder in the folder path,
  # plus the last folder in the remaining string, recursively.
  def folders(this_folder=nil)
    this_folder ||= folder
    matches = /(^.*\b)(\w+\.theme)\//.match(this_folder)
    if matches[1].eql? 'themes/'
      [matches[1] + matches[2]]
    else
      [matches[1] + matches[2], folders(matches[1])].flatten
    end
  end

  def file(file_name)
    folder = folders.select do |folder|
      File.exist?(File.join([folder, file_name]))
    end.first
    File.read(File.join([folder, file_name]))
  end

end
