desc "Run tests with RSpec."
task :test do
  puts system('rspec -f d --color')
end