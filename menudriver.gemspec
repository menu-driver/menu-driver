
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "menudriver/version"

Gem::Specification.new do |spec|
  spec.name          = "menudriver"
  spec.version       = Menudriver::VERSION
  spec.authors       = ["Ryan Alyn Porter"]
  spec.email         = ["rap@endymion.com"]

  spec.summary       = %q{Fast, reliable, beautiful, universal restaurant menus for the web -- and for your QR codes for service in your restaurant.}
  spec.description   = %q{A serverless microservice built with Ruby for generating web restaurant menus based on data from the Single Platform API, for hosting on AWS S3.}
  spec.homepage      = "https://endymion.github.io/menu-driver/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/endymion/menu-driver"
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.8', '>= 3.8.3'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.23'
  
  spec.add_dependency 'httparty', '~> 0.18.1'
  spec.add_dependency 'hash_dot', '~> 2.4', '>= 2.4.2'
  spec.add_dependency 'aws-sdk-s3', '~> 1.75'
  spec.add_dependency 'awesome_print', '~> 2.0.0.pre2'
  spec.add_dependency 'pry', '~> 0.13.1'
  spec.add_dependency 'toml', '~> 0.2.0'
  spec.add_dependency 'deep_merge', '~> 1.0', '>= 1.0.1'
  spec.add_dependency 'capybara', '~> 3.33'
  spec.add_dependency 'sassc', '~> 2.4'
  spec.add_dependency 'htmlcompressor', '~> 0.4.0'
  spec.add_dependency 'thor', '~> 1.0', '>= 1.0.1'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'aws-sdk-comprehend', '~> 1.36'
end