require "rvm/capistrano"

set :rvm_type, :user
set :rvm_ruby_string, "1.9.3"

role :web, "sparta"

desc "update code and rebuild public files"
task :deploy do
  run "cd /home/barbuza/django/vk-feed && git pull && bundle install && cd viewer && bundle install && bundle exec middleman build"
end

desc "fetch new data from vk and make seeds"
task :update do
  run "cd /home/barbuza/django/vk-feed && bundle exec rake vk:fetch && bundle exec rake vk:seed"
end

desc "cleanup database"
task :cleanup do
  run "cd /home/barbuza/django/vk-feed && bundle exec rake db:cleanup"
end

