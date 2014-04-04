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
  end

  class Query
    def self.strict str, db
      q = CFS::Parser.parse_line str

      r = CFS::Container.new
      db.children.each {|c|
        if c < q
          r.add c
        end
      } 

      r
    end    
    def self.strict_2 str, db
      q = CFS::Parser.parse_line str

      puts "Query:"
      puts q.to_s

      r = CFS::Container.new
      db.children.each {|c|
        tmp = query_match q, c
        if tmp
          r.add tmp
        end
      } 

      puts "Result:"
      puts r.to_s

      r
    end    

    def self.query_match q, c
      if c.name
        if q.name 
          # c = a:b
          # q = x:y
          if q.name == c.name
            # a == x
            if q.is_collection?
              # => check next criteria
              # TODO
              r = CFS::Container.new q.name

              q.children.all? {|q_i|
                c.children.any?{|c_i|
                  query_match q_i, c_i
                }
              } ? c : nil
            else 
              c
            end
          else
            # a != x
            # => don't match
            nil
          end
        else
          if q.is_collection?
            # c = a:b
            # q = (x, y, ...)
            # => don't match
            nil
          else
            # c = a:b
            # q is empty => all criteria fulfilled
            c  
          end
        end
      else
        if q.name
          # c = (a, b, c)
          # q = a:b
          c.children.any? {|c_i|
            query_match q, c_i
          } ? c : nil
        else
          # c = (a, b, c)
          # q = (x, y, z)
          # For all There Exists ...
          # Suppose that q.is_collection?
          q.children.all? {|q_i|
            c.children.any?{|c_i|
              query_match q_i, c_i
            }
          } ? c : nil
        end
      end
    end
  end
end
