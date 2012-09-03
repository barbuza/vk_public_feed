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


class Rufus::Tokyo::TableQuery

  def exclude_texts(texts)
    texts.each{ |text| add "text", :eq, text, false }
  end

  def exclude_indicies(indicies)
    indicies.each{ |ind| add "index", :numeq, ind, false }
  end

end


module Build

  def seed_random_pages
    dbs = CONFIG.groups.collect{ |group| Store.new group }.reject{ |db| db.size == 0 }
    begin
      indicies = Hash[dbs.collect{ |db| [db, []] }]
      texts = Hash[dbs.collect{ |db| [db, []] }]
      puts "collecting comments"
      (1..CONFIG.random_pages).each do |page|
        puts "page #{page}"
        comments = []
        big = 0
        middle = 0
        while comments.size < CONFIG.per_page
          db = dbs.sample
          index = nil
          while not index or indicies[db].include? index
            index = db.min_index + rand(db.size)
          end
          if big < 3
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numgt, 100
              q.add "index", :numgt, index
              q.order_by "index", :numasc
            }.first
            big += 1 if comment 
          elsif middle < 3
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numgt, 45
              q.add "length", :numle, 100
              q.add "index", :numgt, index
              q.order_by "index", :numasc
            }.first
            middle += 1 if comment
          else
            comment = db.query{ |q|
              q.exclude_indicies indicies[db]
              q.exclude_texts texts[db]
              q.add "length", :numle, 45
              q.add "index", :numgt, index
              q.order_by "index", :numasc
            }.first
          end
          if comment
            comment_data = comment.hash_with(%w{username avatar text}).force_unicode
            comments << comment_data
            indicies[db] << index
            texts[db] << comment_data["text"]
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
