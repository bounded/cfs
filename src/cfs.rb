require 'set'
require 'pry'

module CFS

  class Container

    def initialize name=nil, children=Set.new
      self.name = name if name
      @children = Set.new
      children.each {|x| add x}
    end

    def name= str
      unless str.is_a? String
        raise ArgumentError, str.to_s + " (#{str.class})"
      end
      @name = str
    end

    def name
      @name
    end

    def children
      @children
    end

    def ==(o)
      o.is_a?(CFS::Container) && @name == o.name && @children == o.children
    end

    def eql?(o)
      self == o
    end

    def hash
      @name.hash
    end

    def is_leaf?
      name != nil && @children.empty?
    end

    def is_collection?
      !@children.empty?
    end

    def to_s
      if is_leaf?
        @name
      elsif is_collection?
        if @children.length == 1 and @children.to_a[0].is_leaf?
          "{#{@name}: #{@children.to_a[0].to_s}}"
        else
          s = "{"
          if @name
            s += "\n  " + @name + ": "
          end
          s += "\n"
          s += @children.map{ |c| 
            c.to_s.lines.map{ |x|
              "  " + x
            }.join
          }.join(",\n")
          s += "\n}"
          s
        end
      end
    end

    def inspect
      "#<#{self.class}: (#{@name ? @name : "nil"}, [#{@children.map {|c| c.inspect}.join ", "}])>"
    end

    def add c
      unless c.is_a? Container
        raise ArgumentError, "Cannot add #{c} to #{self.to_s}"
      end
      @children << c
    end
  end
end
