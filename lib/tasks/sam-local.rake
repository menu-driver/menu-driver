namespace :server do

  desc "Start the SAM Local HTTP server."
  task :start do
    command = <<-EOC
      sam local start-api -p 8080 --docker-network menu-driver --static-dir \"\" &
    EOC
    puts 'running: ' + command
    puts system command
  end

end