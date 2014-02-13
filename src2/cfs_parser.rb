require_relative 'cfs.rb'

module CFS
  class Parser
    def initialize db=CFS::Database.new
      @db = db
    end

    def database str
      arr = tokenize str, ({
        ',' => :comma,
        ':' => :colon,
        "\n" => :newline
      })
    end

    def query str

    end

    def self.tokenize str, rpl
      
    end

  end
end

class Array
  def split obj
    i = index obj
    if i == nil
      [self]
    else
      [self[0..i-1]] + self[i+1..-1].split(obj)
    end
  end
end
