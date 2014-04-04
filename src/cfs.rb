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

    def is_named?
      !is_leaf? && name != nil
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

    def child
      raise ArgumentError if @children.length != 1
      @children.to_a[0]
    end

    def minimize
      # partition in
      # group 1: starts with a => recursive
      # group 2: starts with b => recursive
      # ...
      # group n: remainder, stop 
      #

      r = CFS::Container.new @name

      part = {}
      @children.each {|c|
        if c.name
          if part[c.name]
            part[c.name] << c
          else
            part[c.name] = [c]
          end
        else
          r.add c.minimize
        end
      }

      part.each_pair {|k, cs|
        if cs.length == 1
          r.add cs[0]
          next
        end

        # cs contains k:a_1, k:a_2, ... , k:a_n
        # create k:(a_1, a_2, ... , a_n)
        
        tmp = CFS::Container.new k
        cs.each {|cs_i|
          if cs_i.children.length == 1
            tmp.add cs_i.child
          end
        }

        if tmp.children.length > 0
          tmp = tmp.minimize
          r.add tmp
        else
          cs.each{|c_i| 
            r.add c_i
          }
        end
      }

      if r.children.length == 1 and r.name == nil
        r = r.child
      end
      r
      
    end

    def empty?
      @children.empty?
    end
  end
end
