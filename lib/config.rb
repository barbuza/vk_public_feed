require "yaml"

class Cfg

  class << self

    def path(filename)
      File.expand_path "#{File.dirname __FILE__}/../#{filename}"
    end

    YAML.load_file(File.expand_path "#{File.dirname __FILE__}/../config.yml").each_pair do |key, value|
      define_method key do
        value
      end
    end

  end

end
