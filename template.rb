generate(:controller, "pages index")
route "root to: 'pages#index'"
# gems
gem 'haml-rails'
gem 'bootstrap-sass'
if yes?('Install Devise?')
  gem 'devise'
end
if yes?('Deploy on heroku?')
  gem_group :production do
    gem 'rails_12factor'
  end
end

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial' }
end
