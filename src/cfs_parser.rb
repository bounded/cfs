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
      })
      
      tss = tss.split :newline


      tss.map! {|ts|

        if ts.length == 0
          [:EMPTY]
        elsif ts.length == 1
          if ts[0] =~ /[\s]*/
            [:EMPTY]
          else
            ts[0].strip!
            if is_quoted ts[0]
              [:LITERAL_QUOTED, ts[0]]
            else
              [:LITERAL, ts[0]]
            end
          end
        else

        prefix = ts.last == :colon or
                 (ts.length > 1 && ts[-1] =~ /[\s]*/)

        if prefix
          [:PREFIX, ts]
        else


        ts_coms = ts.split :comma
        ts_coms.map! {|ts_com|

          ts_cols = ts_com.split :colon

          ## TODO 
          # wont work because parse_literal
          # needs the context of the preivously
          # parsed elements
          #
          # e.g. a:b:c
          #
          # b needs a
          ts_cols.map! {|ts_col|
              [parse_literal(ts_col[0])]
          }
          
          ts_cols.flatten_by :colon
        }
        ts_coms.flatten_by :comma

        end
        end

      }

      buffer = []
      prefix = nil
      result = CFS::Database.new

      until tss.empty?
        ts = tss.pop
        
        # prefix
        # if prefix at the end => top node
        
        # empty line
        
        # literal ending with "..."

        # other literals
      end

    end

    def parse_literal l
      l.strip!

      q1 = l.first == '"' and l.last == '"'
      q2 = l.first == "'" and l.last == "'"
      if q1 or q2
        l.materialize_quotes!
      else
        l.materialize_quotes!
        return l
        l_approx = find_approx_literal l
        l = l_approx if l_approx

        # TODO heuristic
        unless l_approx and l.length >= 20
          return nil
        end
      end

      l
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
  def flatten_by obj
    r = []
    obj.each {|x|
      r += x
      r << obj
    }
    r.pop
    r
  end
end
