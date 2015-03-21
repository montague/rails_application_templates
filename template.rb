# gems
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'puma'
gem 'quiet_assets'

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
end

gem_group :development do
  gem 'rack-mini-profiler'
  gem 'meta_request'
end

if yes?('Install Devise?')
  gem 'devise'
end

if yes?('Deploy on heroku?')
  gem_group :production do
    gem 'rails_12factor'
  end
  gem 'rack-timeout'

  environment %{
  # quiet logging noise from Rack::Timeout
  # https://github.com/heroku/rack-timeout#logging
  Rack::Timeout.unregister_state_change_observer(:logger)
  }, env: 'development'

  initializer 'timeout.rb', <<-CODE
# recommended by heroku
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout
Rack::Timeout.timeout = 20  # seconds
CODE

  file 'config/puma.rb', <<-CODE
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
CODE


  file 'Procfile', <<-CODE
web: bundle exec puma -C config/puma.rb
CODE

end # end deploy on heroku block

generate(:controller, "pages home")
route "root to: 'pages#home'"


if yes?('Init empty repo?')
  after_bundle do
    git :init
    git add: "."
    git commit: %Q{ -m 'Initial' }
  end
end
