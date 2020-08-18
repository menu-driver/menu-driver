desc "Run tests with RSpec."
task :test do
  command = 'rspec'
  puts 'running: ' + command
  puts system(command)
end
