require "json"
require_relative "./config.rb"
require_relative "./store.rb"

module Build

  def mongo_seed_random_pages
    MongoStore.open do |db|
      puts "collecting comments"
      short = db.random_by_length :short, Cfg.random_pages * 3
      medium = db.random_by_length :medium, Cfg.random_pages * 3
      long = db.random_by_length :long, Cfg.random_pages * 3
      puts "filling pages"
      (1..Cfg.random_pages).each_with_index do |page, index|
        puts "page #{page}"
        comments = short.slice(index * 3, 3) +
                   medium.slice(index * 3, 3) +
                   long.slice(index * 3, 3)
        open("tmp.json", "w") do |f|
          f << JSON.dump(comments)
        end
        File.rename "tmp.json", "#{File.dirname File.expand_path __FILE__}/../viewer/build/pages/#{page}.json"
      end
    end
  end

  def seed_random_pages
    dbs = Cfg.groups.collect{ |group| Store.new group }.reject{ |db| db.size == 0 }
    begin
      indicies = Hash[dbs.collect{ |db| [db, []] }]
      texts = Hash[dbs.collect{ |db| [db, []] }]
      puts "collecting comments"
      misses = 0
      (1..Cfg.random_pages).each do |page|
        puts "page #{page}"
        comments = []
        big = 0
        middle = 0
        while comments.size < Cfg.per_page
          db = dbs.sample
          index = nil
          size = db.size
          min_index = db.min_index
          while not index or indicies[db].include? index
            index = min_index + rand(size)
          end
          if big < 3
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numgt, 100
              q.first_by index
            }.first
            big += 1 if comment
          elsif middle < 3
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numgt, 45
              q.add "length", :numle, 100
              q.first_by index
            }.first
            middle += 1 if comment
          else
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numle, 45
              q.first_by index
            }.first
          end
          if comment
            comment_data = comment.hash_with(%w{username avatar text}).force_unicode
            comments << comment_data
            indicies[db] << index
            texts[db] << comment_data["text"]
          else
            misses += 1
          end
        end
        open("tmp.json", "w") do |f|
          f << JSON.dump(comments)
        end
        File.rename "tmp.json", "#{File.dirname File.expand_path __FILE__}/../viewer/build/pages/#{page}.json"
      end
      puts "miss rate #{100 * misses / (Cfg.random_pages * Cfg.per_page)}%"
    ensure
      dbs.each &:close
    end
  end

end
