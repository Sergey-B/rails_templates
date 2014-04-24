# Rails template appication file for  gem 'deployconfig'
#USAGE
#rails new app_name -m template.rb

application_name = ARGV[0]

#Gemfile

gem 'jbuilder', '~> 1.2'

# Assets pipeline
gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'

gem_group :development do
  gem 'sqlite3'

  # Annotate models
  gem 'annotate'

  # Debuging and profiling
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'lol_dba'
  gem "bullet"

  # Code styling
  gem 'rails_best_practices'
  gem 'mago'
  gem 'rubocop'

  # Deploy
  gem 'deployconfig', '0.1.0', git: 'ssh://git@oldgit.snpdev.ru:42204/deployconfig.git', branch: 'separate_deploy'
  gem 'capistrano', '~> 2.15'
  gem 'net-ssh', '2.7.0'
  gem 'capistrano-ext'
end

gem_group :production do
  gem 'pg'
  gem 'unicorn'
end

# ENV variables
gem 'figaro'

run 'bundle install'

#Create config/deploy.rb
file 'config/deploy.rb', <<-CODE
# encoding: utf-8
require 'deploy_config'
set :application, "#{ARGV[0]}"
set :git_application_name, application

set :symlinks,  [
  { label: :db, path: 'config/database.yml' },
  { label: :dotenv, path: '.env' },
  { label: :figaro, path: 'config/application.yml' }
]
set :use_sudo, false
set :stages, %w(testing production)
default_run_options[:pty] = true
set :rbenv_ruby_version, '2.0.0-p451'
set :repository, "git@git.snpdev.ru:saltpepper/#{git_application_name}.git"
set :bundle_flags, '--deployment'
set :ssh_default_dir, "/var/www/#{application}/ss/current"

CODE

#Write to Capfile "load 'deploy/assets'"
file 'Capfile',<<-CODE
load 'deploy'
# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks
CODE

run 'capify .'

#Create config/deploy/testing.rb and config/deploy/production.rb
run 'rails g deploy'

#Create unicorn.rb in config/deploy/
run 'rails g unicorn'
