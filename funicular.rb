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
  gem 'simplecov'
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
# Setup a better Rakefile
###############################

rakefile 'default.rake' do
  %Q{
require 'rake-n-bake'

task default: %i[
  bake:code_quality:all
  bake:rspec
  bake:coverage:check_specs
  bake:bundler_audit
  bake:ok_rainbow
]
}
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
  ###############################
  # Rspec
  ###############################

  generate(:'rspec:install')
  inject_into_file 'spec/rails_helper.rb', "require 'capybara/rails'\nrequire 'capybara/rspec'\nrequire 'support/database_cleaner'\n", after: "require 'rspec/rails'\n"
  inject_into_file 'spec/rails_helper.rb', "config.include FactoryGirl::Syntax::Methods", after: /config.fixture_path.*\n/
  create_file 'spec/features/homepage_spec.rb' do
    %Q{require 'rails_helper'

describe 'Visiting the homepage' do
  it 'does something cool'
end
}
  end

  ###############################
  # Database Cleaner
  ###############################

  create_file 'spec/support/database_cleaner.rb' do
%Q{require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
}
  end


  ###############################
  # Misc niceities
  ###############################

  run 'guard init'

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
