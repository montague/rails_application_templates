generate(:controller, "pages index")
route "root to: 'pages#index'"
# gems
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'puma'
if yes?('Install Devise?')
  gem 'devise'
end
if yes?('Deploy on heroku?')
  gem_group :production do
    gem 'rails_12factor'
  end
  gem 'rack-timeout'

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

end

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial' }
end
