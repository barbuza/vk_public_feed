require "open-uri"
require "nokogiri"
require_relative "./config.rb"
require_relative "./store.rb"


module Fetch


  def parse_vk_date(date_str)
    if date_str =~ /Yesterday/
      dt = DateTime.parse(date_str) - Rational("7/6")
    elsif date_str =~/Today/
      dt = DateTime.parse(date_str) - Rational("1/6")
    end
  end


  def is_actual_time(dt)
    (DateTime.now - dt) < Rational("1/6")
  end


  def collect_posts(group)
    url = "http://m.vk.com/#{group}"
    puts "<= #{url}"
    Nokogiri::HTML(open url).css(".posts .post").each do |div|
      link = div.css(".info .date").first
      post_id = link.attr :href
      dt = parse_vk_date link.content
      next unless dt
      next unless is_actual_time dt
      yield post_id
    end
  end


  def check_comment_text(text)
    text.size > 2 && ! text =~ /https?:\/\//
  end


  def collect_comments(group)
    Store.open(group) do |db|
      max_index = db.max_index
      collect_posts(group) do |post_url|
        begin
          comments = true
          offset = 0
          while comments
            url = "http://m.vk.com#{post_url}?offset=#{offset}"
            puts "<- #{url}"
            comments = Nokogiri::HTML(open url).css(".replies .post")
            offset += 50
            break if offset > 150
            added = 0
            comments.each do |div|
              begin
                avatar = div.css("img.u").first.attr :src
                username = div.css("a.user").first.content
                text = div.css(".cc .text").first.content
                comment_id = div.css(".info .date").first.attr :href
              rescue Exception => error
                next
              end
              unless db[comment_id]
                if check_comment_text text
                  max_index += 1
                  db[comment_id] = {avatar: avatar, username: username, text: text, index: max_index}
                  added += 1                  
                end
              else
                comments = false
              end
            end
            puts "+ #{added}" if added > 0
            break if !comments || comments.size < 50
          end
        rescue Exception => error
          puts "failure: #{error}"
        end
      end
    end
  end


end