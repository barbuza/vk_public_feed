require "haml"
require "uglifier"
require "coffee-script"
require "json"
require_relative "./config.rb"
require_relative "./store.rb"


module Coffee
  module Filter
    module Coffeescript
      include ::Haml::Filters::Base

      def render_with_options(text, options)
        <<END
<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>
  //<![CDATA[
    #{Uglifier.compile CoffeeScript.compile text}
  //]]>
</script>
END
      end
    end
  end
end


module Build

  def build_public_files
    puts "building index.html"
    open("#{File.dirname File.expand_path __FILE__}/../public/index.html", "w") do |index|
      engine = Haml::Engine.new open("#{File.dirname File.expand_path __FILE__}/../index.haml").read
      index << engine.render
    end
  end

  def seed_random_pages
    total = CONFIG.random_pages * CONFIG.per_page
    dbs = CONFIG.groups.collect{ |group| Store.new group }
    comments = []
    puts "collecting comments"
    while comments.size < total
      db = dbs.sample
      next if db.size == 0
      comment = db.by_index(rand(db.size) + 1)
      comments << comment if comment and not comments.find{ |c| c[:pk] == comment[:pk] }
    end
    comments.shuffle!
    comments.each do |c|
      c.delete :pk
      c.delete "index"
      c.each_pair do |k,v|
        c[k] = v.force_encoding "UTF-8"
      end
    end
    puts "creating json files"
    (1..CONFIG.random_pages).each do |page|
      open("tmp.json", "w") do |f|
        f << JSON.dump(comments.slice((page - 1) * CONFIG.per_page, CONFIG.per_page))
      end
      File.rename "tmp.json", "#{File.dirname File.expand_path __FILE__}/../public/#{page}.json"
    end
  end

end
