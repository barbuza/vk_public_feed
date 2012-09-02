require "yaml"

class Cfg

  attr_reader :groups, :random_pages, :per_page

  def initialize
    filename = File.join (File.dirname File.dirname File.expand_path __FILE__), "config.yml"
    YAML.load_file(filename).each_pair do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

end

CONFIG = Cfg.new
