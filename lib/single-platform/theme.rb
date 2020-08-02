class SinglePlatform::Theme
  
  def initialize(theme)
    @theme_name =
      # Select the theme name.
      theme || 'default'
  end

  def folder
    Dir.glob('themes/**/*/').select{|folder| folder =~ /\.theme\/$/}.
      select do |folder|
        /([^\.\/]+)\.theme\/$/.match(folder)[0].include? @theme_name
      end.first
  end

  def file(file_name)
    File.read(File.join([folder, file_name]))
  end

end