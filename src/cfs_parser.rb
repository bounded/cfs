require_relative 'cfs.rb'

module CFS
  class Parser
    def initialize db=CFS::Database.new
      @db = db
    end

    def database str
      tss = tokenize str, ({
        ',' => :comma,
        ':' => :colon,
        "\n" => :newline
      }
      
      tss = tss.split(:newline).map {|ts|
        if ts.empty? or (ts.length == 1 and ts[0] =~ /[\s]*/)
          [:EMPTY]
        else

        end
      }
      
    end

    def query str

    end

    def self.canonical db

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
