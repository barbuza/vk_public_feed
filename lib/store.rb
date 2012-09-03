require "rufus/tokyo"


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
