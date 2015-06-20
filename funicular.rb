###############################
# Setup a tidier gemfile
###############################

gem 'sass-rails'
gem 'haml-rails'
gem 'therubyracer',  platforms: :ruby
gem 'uglifier'
gem 'rake-n-bake'

gem_group :development, :test do
  gem 'spring'
  gem 'pry-byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'meta_request'
  gem 'web-console'
end

gem_group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'capybara'
end

gem_group :development do
  gem 'coffee-rails-source-maps'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'bullet'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'guard-bundler', require: false
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'erb2haml'
  gem 'metric_fu', require: false
  gem 'rubocop', require: false
  gem 'sandi_meter', require: false
end


###############################
# Remove some default cruft
###############################

run "rm README.rdoc"
gsub_file 'Gemfile', /#.*\n/, ''

# Sorry Spring, you tend to just complicate things
gsub_file 'Gemfile', /gem 'spring.*\n/, ""

# So long, turbolinks
gsub_file 'Gemfile', /gem 'turbolinks.*\n/, ""
gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks.*\n/, ""
gsub_file 'app/views/layouts/application.html.erb', ", 'data-turbolinks-track' => true", ''

# Addios, JQuery
gsub_file 'Gemfile', /gem 'jquery.*/, ""
gsub_file 'app/assets/javascripts/application.js', /\/\/= require jquery.*\n/, ""

###############################
# Setup some nice things
###############################

after_bundle do
  generate(:'rspec:install')

  inject_into_file 'spec/rails_helper.rb', "require 'capybara/rspec'", after: "require 'rspec/rails'\n"
  inject_into_file 'spec/rails_helper.rb', "config.include FactoryGirl::Syntax::Methods", after: /config.fixture_path.*\n/

  rake "haml:replace_erbs"

  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
  say 'Inital commit created'

  rake 'db:create db:migrate db:setup' unless no?("Would you like the database creating? (Y/n)", :yellow)

  ###############################
  # Pull into the station
  ###############################

  say '                    /\\',           :blue
  say '                   /  \\',          :blue
  say '                  /    \\',         :blue
  say '                 /      ^^\\',      :blue
  say '                /          \\',     :blue
  say '               /\/\/\/\/\/\/\\',    :blue
  say '              /              \\',   :blue
  say '             /                \\',  :blue
  say '            /                  \\', :blue
  say '           ----------------------', :blue
  say 'Thank you for choosing the DevMountain Funicular Rails-way!'
end
