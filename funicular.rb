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
end

gem_group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'simplecov'
  gem 'poltergeist'
end

gem_group :development do
  gem 'meta_request'
  gem 'coffee-rails-source-maps'
  gem 'spring-commands-rspec'
  gem 'erb2haml',         require: false

  gem 'guard-bundler',    require: false
  gem 'guard-rspec',      require: false
  gem 'guard-rails',      require: false
  gem 'guard-livereload', require: false

  gem 'brakeman',         require: false
  gem 'bullet',           require: false
  gem 'bundler-audit',    require: false
  gem 'fasterer',         require: false
  gem 'metric_fu',        require: false
  gem 'rubocop',          require: false
  gem 'sandi_meter',      require: false
end

###############################
# Setup a better Rakefile
###############################

rakefile 'default.rake' do
  %Q{
require 'rake-n-bake'

task default: %i[
  bake:check_external_dependencies
  bake:code_quality:all
  bake:rspec
  bake:coverage:check_specs
  bake:rails_best_practices
  bake:bundler_audit
  notes
  bake:ok_rainbow
]
}
end

###############################
# Setup a better Seeds file
###############################
remove_file 'db/seeds.rb'
create_file('db/seeds.rb') do
%q{
puts 'Loading seeds...'
Dir[File.join Rails.root, 'db', 'seeds', 'all', '*.rb'].each do |file|
  puts "  -> #{File.basename file}"
  require file
end

if Rails.env == 'development'
  puts 'Loading development seeds...'
  Dir[File.join Rails.root, 'db', 'seeds', 'development', '*.rb'].each do |file|
    puts "  -> #{File.basename file}"
    require file
  end
end
}
end

empty_directory 'db/seeds'
empty_directory 'db/seeds/all'
empty_directory 'db/seeds/development'

create_file 'db/seeds/all/example.rb' do
  %q{
# Create files in this directory to create your seed data .
# For example:
#   User.where(name: "Admin").first_or_create(name: "Admin", homepage: "http://devmountain.co.uk", role: :admin)
}
end

create_file 'db/seeds/development/example.rb', '# Create files in this directory to add seed data just for development. See db/seeds/all/example.rb for more.'

###############################
# Remove some default cruft
###############################

run "rm README.rdoc"
gsub_file 'Gemfile', /#.*\n/, ''

# So long, turbolinks
gsub_file 'Gemfile', /gem 'turbolinks.*\n/, ""
gsub_file 'app/assets/javascripts/application.js', /\/\/= require turbolinks.*\n/, ""
gsub_file 'app/views/layouts/application.html.erb', ", 'data-turbolinks-track' => true", ''

###############################
# Setup a more helpful Sass
###############################

create_file 'app/assets/stylesheets/reset.scss' do
%Q{*{
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-size: 16px;
}
}
end

create_file 'app/assets/stylesheets/variables.scss' do
%Q{$border-radius: 3px;
}
end

create_file 'app/assets/stylesheets/mixins.scss' do
%Q{@mixin border-radius($radius: $border-radius) {
  -webkit-border-radius: $radius;
     -moz-border-radius: $radius;
      -ms-border-radius: $radius;
          border-radius: $radius;
}
}
end

remove_file 'app/assets/stylesheets/application.css'
create_file 'app/assets/stylesheets/application.css.scss' do
%Q{@import "variables";
@import "reset";
@import "mixins";
}
end

###############################
# Setup some nice things
###############################

after_bundle do
  ###############################
  # Rspec
  ###############################

  generate(:'rspec:install')
  inject_into_file 'spec/rails_helper.rb',
    %Q{
  require 'capybara/rails'
  require 'capybara/rspec'
  require 'support/database_cleaner'
  require 'shoulda/matchers'
  },
    after: "require 'rspec/rails'\n"

  inject_into_file 'spec/rails_helper.rb',
    "  config.include FactoryGirl::Syntax::Methods",
    after: /config.fixture_path.*\n/

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
  prepend_to_file( 'Guardfile', 'notification :tmux, display_message: true' )
  gsub_file 'Guardfile', /watch\(rails.view_dirs\).*/, 'watch(rails.view_dirs)     { |m| "#{rspec.spec_dir}/features/#{m[1]}" }'
  gsub_file 'Guardfile', /watch\(rails.layouts\).*/,   'watch(rails.layouts)       { |m| "#{rspec.spec_dir}/features" }'

  run 'bundle exec spring binstub rspec'

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
