require './cfs_parser.rb'

module CFS
  class Container
    def <= (o)
      self == o or self < o
    end

    def < (o)
      if self.is_leaf? 
        false
      elsif self.is_collection? and o.is_leaf?
        if self.is_named? && self.name == o.name
          return true
        end
        @children.any? {|x|
          x <= o
        }
      else
        if self.is_named? && o.is_named?
          if self.name == o.name
            o.children.all? {|o_i|
              self.children.any? {|s_i|
                s_i <= o_i
              }
            }
          else
            false
          end
        elsif self.is_named? && !o.is_named?
          false
        elsif !self.is_named? && o.is_named?
          self.children.any? {|x|
            x <= o
          }
        else
          o.children.all? {|o_i|
            self.children.any? {|s_i|
              s_i <= o_i
            }
          }
        end
      end
    end

    def > (o)
      o < self
    end

    def >= (o)
      self == o || self > o
    end
  end

  class Query
    def self.strict str, db
      q = CFS::Parser.parse_line str
      query q, db
    end    

    def self.query q, db
      r = CFS::Container.new
      db.children.each {|c|
        if c < q
          r.add c
        end
      } 

      r
    end
  end
end
