require_relative "./lib/fetch.rb"
require_relative "./lib/build.rb"

include Fetch
include Build

namespace :vk do

  desc "fetch comments from vk"
  task :fetch do
    CONFIG.groups.each{ |group| collect_comments group }
  end

  desc "create json files with random comments"
  task :seed do
    seed_random_pages
  end

  desc "create public files"
  task :build do
    build_public_files
  end

end