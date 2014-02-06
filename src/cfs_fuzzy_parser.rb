require_relative 'cfs.rb'
require_relative 'cfs_fuzzy_parser_containers.rb'
require_relative 'cfs_fuzzy_parser_literals.rb'
require_relative 'cfs_fuzzy_utils.rb'

module CFS
  class FuzzyParser
    def initialize data=CFS::Database.new
      self.db = data
    end 

    def db=(db)
      @db = db
      process_db
    end 

    def process_db
      cs = []
      @db.each { |l|
        cs += l.containers.to_a
      }
      cs.delete_if {|x|
        cs.any? {|y|
          x != y && (y.implies? x)
        }
      }
      @info = {
        :cs => cs
      }
    end

    # Canonical representation of a database
    # in the sense that the produced string
    # can be unambiguously transformed back
    # into a database using #literals

    def self.canonical db
      db.map {|l|
        l_esc = l.escape ['"', "'", '\\', ':', ',']
        
        cs_esc = l.containers.map{|x| 
          x.map{|y|
            y_esc = y.escape ['"', "'"]
            if ['\\', ' ', ':', ','].any? {|z| y.include? z}
              '"' + y_esc + '"'
            else
              y_esc
            end
          }.join " "
        }
        
        cs_str = cs_esc.join(", ") + ": " 
        if l_esc.include? "\n" 
          cs_str + "\n" + l_esc
        else
          cs_str + l_esc
        end
      }.join "\n" 
    end
  end
end

class String
  
  def escape arr
    r = self
    arr.each {|x| 
      r = r.gsub(x, '\\' + x)
    }
    r
  end

  # input: a" b c\": hell"o.mat_quotes! /[ :]/
  # output: a\ b\ c":\ hello
  def materialize_quotes! r_escape
    i = 0
    in_q = false
    q_type = nil

    while i < length
      if in_q 
        if self[i] == q_type 
          if i != 0 and self[i-1] == "\\"
            self[i-1] = ""
          else
            in_q = false
            q_type = nil
            self[i] = ""
          end
        elsif self[i] =~ r_escape
          self[i] = '\\' + self[i]
          i += 2
        else
          i += 1
        end
      elsif ['"', "'"].include?(self[i]) 
        if i != 0 and self[i-1] == "\\"
          self[i-1] = ""
        else
          in_q = true
          q_type = self[i]
          self[i] = ""
        end
      else
        i += 1
      end
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
