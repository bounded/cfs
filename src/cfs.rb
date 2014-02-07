require 'set'

module CFS

  DEBUG = false

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
        obj.containers.each {|c| lit.add c}
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
      map{|x| x.to_s }.join "\n"
    end

    def inspect
      map{|x| x.inspect }.join "\n"
    end

    def self.by_hash h
      r = CFS::Database.new
      h.each_pair {|k, v|
        l = CFS::Literal.new k
        l.containers = v.map{|x| CFS::Container.new x}
        r.add l
      }
      r
    end
  end

  class Literal < String
    def initialize str
      super
      @containers = Set.new
    end

    def inspect
      "#<CFS::Literal \"#{self}\", [#{@containers.map{|x|x.to_s}.join ", "}]>"
    end

    def add c
      unless c.is_omega?
        @containers << c if @containers.all? {|x| !(x.implies? c)}
      end
    end

    def in? c
      c.contains? self 
    end

    def containers= c
      @containers = Set.new
      c.each{|x| add x}
    end

    def containers
      @containers
    end

    def containers_s
      containers.map{|y| y.join " "}.join ", "
    end

    def eql?(o)
      self == o && containers == o.containers
    end

    def to_s
      l = self
      if self.length > 25
        l = self[0..22] + "[...]"
      end
      l = l.gsub(/\n/, '\\n')
      containers_s + ": " + l
    end
  end

  class Container < Array
    def contains? obj
      if obj.is_a? Container
        obj.implies? self
      else
        raise ArgumentError unless obj.is_a? Literal
        obj.containers.any? {|x|
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

    def inspect
      "#<#{self.class.name} #{to_s}>"
    end

    def depth
      length
    end

    def is_omega?
      length == 0
    end

    alias :arr_eql :==

    def ==(o)
      o.instance_of?(self.class) && arr_eql(o)
    end
  end

  # matches all literals that contain all of its elements
  class PseudoContainer < Container
    def initialize arr, eql=nil
      super arr
      @eql = eql || ->(a, b){a.index b}
    end
    
    def contains? obj
      if obj.is_a? Container
        obj.implies? self
      else
        raise ArgumentError unless obj.is_a? Literal
        all? {|s|
          @eql.call(obj.downcase, s.downcase)
        }
      end
    end

    def implies? c
      return true if self == c
      c.each {|x|
        b = any? {|y|
          y.index x
        }
        return true if b
      }
      false
    end
  end

  def self.debug str
    puts str if DEBUG
  end
end
