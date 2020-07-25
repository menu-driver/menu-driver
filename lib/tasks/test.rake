desc "Run tests with RSpec."
task :test do
  command = 'rspec -f d --color'
  puts 'running: ' + command
  puts system(command)
end
