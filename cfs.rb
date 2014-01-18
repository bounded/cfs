require 'set'
require './cfs_parser.rb'

module CFS

  class Database < Set
    alias :set_add :add
    def add obj
      raise ArgumentError unless obj.is_a? Literal

      lit = nil
      each {|x|
        # only check actual content
        if x == obj      
          lit = x
        end
      }

      unless lit
        set_add obj
      else
        obj.container.each {|c| lit.add c}
      end
    end

    # intersection of c 
    def filter cs
      tmp = Database.new
      each {|x|
        tmp << x if cs.all?{|c| c.contains? x}
      }
      tmp
    end

    def to_s
      # TODO: tree
      map{|x| x.to_s + " " + x.container_s }.join "\n"
    end

    def inspect
      map{|x| x.inspect }.join "\n"
    end
  end

  class Literal < String

    def initialize str
      super 
      @container = []
    end

    def inspect
      "#<CFS::Literal \"#{to_s}\", [#{@container.map{|x|x.to_s}.join ", "}]>"
    end

    def add c
      @container << c if @container.all? {|x| !(x.implies? c)}
    end

    def in? c
      c.contains? self 
    end

    def container= c
      @container = []
      c.each{|x| add x}
    end

    def container
      @container
    end

    def container_s
      "[" + @container.map{|c| c.to_s}.join(", ") + "]"
    end

    def eql?(o)
      self == o && container == o.container
    end
  end

  class Container < Array
    def contains? obj
      if obj.is_a? Container
        obj.implies? self
      else
        raise ArgumentError unless obj.is_a? Literal
        obj.container.any? {|x|
          x.implies? self 
        }
      end
    end

    def implies? c
      if self == c
        true
      elsif c.length < self.length
        c == self[0..c.length-1]
      else
        false
      end
    end

    def to_s
      map{|x|x.to_s}.join ":"
    end

    def inspect
      "#<CFS::Container #{to_s}>"
    end
  end
end
