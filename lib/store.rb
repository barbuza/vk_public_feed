require "rufus/tokyo"


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

end
