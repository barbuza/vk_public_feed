require "rufus/tokyo"
require "mongo"


class Hash

  def hash_with(keys)
    Hash[keys.zip values_at(*keys)]
  end

  def force_unicode()
    k = keys
    Hash[k.zip values_at(*k).collect{ |v| v.force_encoding "UTF-8"}]
  end

  def tokyo_to_mongo
    unicode = force_unicode
    {
      _id: unicode[:pk],
      username: unicode["username"],
      text: unicode["text"],
      avatar: unicode["avatar"],
      length: unicode["length"].to_i
    }
  end

end


class MongoStore

  def self.open
    db = new
    begin
      yield db
    ensure
      db.close
    end
  end

  def initialize
    @conn = Mongo::Connection.new
    @db = @conn.db "vk-feed"
    @coll = @db.collection "posts"
  end

  def method_missing(meth, *args, &block)
    @coll.public_send meth, *args, &block
  end

  def close
    @conn.close
  end

  def random_by_length(len_type, count)
    length = nil
    if len_type == :short
      length = {"$lt" => 45}
    elsif len_type == :medium
      length = {"$gt" => 45, "$lte" => 100}
    elsif len_type == :long
      length = {"$gte" => 100}
    else
      throw "unknown len type `#{len_type.inspect}`"
    end
    find(length: length).to_a.shuffle.slice(0, count)
  end

end

class Rufus::Tokyo::TableQuery

  def exclude_texts(texts)
    texts.each{ |text| add "text", :eq, text, false }
  end

  def exclude_indicies(indicies)
    indicies.each{ |ind| add "index", :numeq, ind, false }
  end

  def first_by(index)
    asc = rand(2) == 1
    add "index", asc ? :numge : :numle, index
    order_by "index", asc ? :numasc : :numdesc
  end

end

class Store <Rufus::Tokyo::Table

  def self.open(name)
    db = new name
    begin
      yield db
    ensure
      db.close
    end
  end

  def initialize(name)
    super "#{File.dirname File.expand_path __FILE__}/../db/#{name}.tdb"
  end

  def min_index
    min_index = query{ |q|
      q.order_by "index", :numasc
      q.limit 1
    }.first
    if min_index
      min_index["index"].to_i
    else
      0
    end
  end

  def max_index
    max_index = query{ |q|
      q.order_by "index", :numdesc
      q.limit 1
    }.first
    if max_index
      max_index["index"].to_i
    else
      0
    end
  end

  def by_index(index)
    comment = query { |q|
      q.add "index", :numeq, index
      q.limit 1
    }.first
  end

end
