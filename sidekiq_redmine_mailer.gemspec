# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sidekiq_redmine_mailer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexey Kondratenko"]
  gem.email         = ["Ialexey.kondratenko@gmail.com"]
  gem.description   = %q{Asynchronous mail delivery using sidekiq. Integration with redmine}
  gem.summary       = %q{Turning ActiveMailer deliveries asynchronous using the power of sidekiq}
  gem.homepage      = "http://github.com/AlexeyAlexey/sidekiq_redmine_mailer"
  gem.license       = "MIT"

  gem.files         = ["lib/sidekiq_redmine_mailer.rb", 
                       "lib/sidekiq_redmine_mailer/proxy.rb",
                       "lib/sidekiq_redmine_mailer/version.rb",
                       "lib/sidekiq_redmine_mailer/worker.rb"]

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sidekiq_redmine_mailer"
  gem.require_paths = ["lib"]
  gem.version       = Sidekiq::RedmineMailer::VERSION

  gem.add_dependency("activesupport", ">= 3.0")
  gem.add_dependency("actionmailer", ">= 3.0")
  gem.add_dependency("sidekiq", ">= 2.3")

  gem.add_development_dependency('rake')
end
