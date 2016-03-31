$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "devise_mongoid_multi_email/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "devise_mongoid_multi_email"
  s.version     = DeviseMongoidMultiEmail::VERSION
  s.authors     = ["Pedro Gryzinsky"]
  s.email       = ["pedro.gryzinsky@zrp.com.br"]
  s.homepage    = "http://zrp.com.br"
  s.summary     = "ODOT"
  s.description = "ODOT"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 5.0.0.beta3", "< 5.1"

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'devise', '>= 4.0.0.rc1'

end
