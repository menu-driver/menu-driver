namespace :develop do

  desc "Start the development environment."
  task :start do
    Rake::Task['dynamodb:start'].execute
    Rake::Task['server:start'].execute
  end
  
  desc "Stop the development environment."
  task :stop do
    puts system('pkill -f "sam local";')
  end

  desc "Stop and restart the development environment."
  task :restart do
    Rake::Task['develop:stop'].execute
    Rake::Task['develop:start'].execute
  end

end