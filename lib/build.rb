require "json"
require_relative "./config.rb"
require_relative "./store.rb"

KEEP_KEYS = %w(username avatar text)


class Hash

  def hash_with(keys)
    Hash[keys.zip values_at(*keys)]
  end

  def force_unicode()
    k = keys
    Hash[k.zip values_at(*k).collect{ |v| v.force_encoding "UTF-8"}]
  end

end


module Build

  def seed_random_pages
    dbs = CONFIG.groups.collect{ |group| Store.new group }.reject{ |db| db.size == 0 }
    begin
      all = []
      puts "collecting comments"
      (1..CONFIG.random_pages).each do |page|
        puts "page #{page}"
        comments = []
        big = 0
        middle = 0
        while comments.size < CONFIG.per_page
          db = dbs.sample
          index = db.min_index + rand(db.size)
          if big < 3
            comment = db.query{ |q|
              q.add "length", :numgt, 100
              q.add "index", :numgt, index
              q.order_by "index", :numasc
            }.first
            big += 1 if comment and not all.include? comment[:pk]
          elsif middle < 3
            comment = db.query{ |q|
              q.add "length", :numgt, 60
              q.add "index", :numgt, index
              q.order_by "index", :numasc
            }.first
            middle += 1 if comment and not all.include? comment[:pk]            
          else
            comment  = db.by_index index
          end
          if comment and not all.include? comment[:pk]
            comments << comment.hash_with(%w{username avatar text}).force_unicode
            all << comment[:pk]
          end
        end
        open("tmp.json", "w") do |f|
          f << JSON.dump(comments)
        end
        File.rename "tmp.json", "#{File.dirname File.expand_path __FILE__}/../viewer/build/pages/#{page}.json"
      end
    ensure
      dbs.each &:close
    end
  end

end
