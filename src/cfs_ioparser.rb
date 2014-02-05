require_relative 'cfs.rb'
require_relative 'cfs_fuzzy_tokenizer.rb'

module CFS
  # TODO does not support empty newline in literal or in container
  module IOParser
    def self.read str
      r = CFS::Database.new

      str.split("\n\n").each {|b|
        i = b.index "\n"

        cs = b[0..(i-1)]
        cs = CFS::FuzzyParser.strict_tokenize_literals_cs cs
        cs = cs.split(:comma).map{|x| CFS::Container.new x}

        l = CFS::Literal.new(b[(i+1)..-1].chomp)
        l.containers = cs
        r.add l
      }

      r
    end

    def self.write db
      r = []
      
      db.dup.each {|l|
        raise ArgumentError if l =~ /\n\n+/
        raise ArgumentError if l.containers.empty?
        raise ArgumentError if l.containers.any?{|x| x.include? "\n"}
        
        l << "\n" unless l[-1] == "\n"
        cs = []
        l.containers.each {|c|
          c_s = c.to_quoted_s
          cs << c_s
        }
        r << "#{cs.join ", "}\n#{l}"
      }

      r.join "\n"
    end
  end

  class Container
    def to_quoted_s
      map {|x|
        x.gsub(/[ ,"]/, ' ' => '\\ ', ',' => '\\ ,', '"' => '\\"')
      }.join " "
    end
  end
end
