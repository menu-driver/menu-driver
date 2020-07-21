namespace :server do

  desc "Start the SAM Local HTTP server."
  task :start do
    puts system <<-EOC
      sam local start-api -p 8080 --docker-network menu-driver --static-dir \"\" &
    EOC
  end

end