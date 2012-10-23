require_relative "./lib/fetch.rb"
require_relative "./lib/build.rb"
require_relative "./lib/config.rb"

include Fetch
include Build

namespace :vk do

  desc "fetch comments from vk"
  task :fetch do
    Cfg.groups.each{ |group| collect_comments group }
  end

  desc "create json files with random comments"
  task :seed do
    seed_random_pages
  end

end

namespace :db do

  desc "convert from tokyo to mongo"
  task :convert_to_mongo do
    MongoStore.open do |mongo_db|
      Cfg.groups.each do |group|
        Store.open(group) do |tokyo_db|
          mongo_db.create_index [["length", Mongo::ASCENDING]]
          mongo_db.create_index [["length", Mongo::DESCENDING]]
          mongo_db.create_index [["length", Mongo::ASCENDING], ["length", Mongo::DESCENDING]]
          tokyo_db.query.each do |item|
            mongo_db.insert item.tokyo_to_mongo
          end
        end
      end
    end
  end

  # desc "clean old comments"
  # task :cleanup do
  #   limit = 10000
  #   Cfg.groups.each do |group|
  #     Store.open(group) do |db|
  #       if db.size > limit
  #         max_index = db.max_index - limit
  #         db.query{ |q| q.add "index", :le, max_index }.each do |rec|
  #           db.delete rec[:pk]
  #         end
  #       end
  #     end
  #   end
  # end

end
