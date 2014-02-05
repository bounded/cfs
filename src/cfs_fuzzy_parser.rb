require_relative 'cfs.rb'
require_relative 'cfs_fuzzy_parser_containers.rb'
require_relative 'cfs_fuzzy_parser_literals.rb'
require_relative 'cfs_fuzzy_utils.rb'

module CFS
  class FuzzyParser
    def initialize db=CFS::Database.new
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

    # returns CFS::Database
    def literals s
      tks = CFS::FuzzyParser.tokenize_literals s
      r = CFS::Database.new
      return r if s.empty?

      top_cs = []

      tks.split(:break).each {|bl|
        if bl.length == 1
          # literal
          
          l = CFS::Literal.new bl[0]
          l.containers = top_cs
          r.add l
        else 
          # tag1, tag2:
          # or 
          # tag1, tag2: literal
          
          l = bl.pop
          if l == :colon
            l = nil
          else
            l = CFS::Literal.new l
            bl.pop
          end

          bl.split(:comma).each {|c|
            # TODO
            # super container, spelling mistake etc.
            c = CFS::Container.new c
            if l 
              l.add c
            else
              top_cs << c
            end
          }

          r.add l if l
        end
      }

      r
    end

    # Canonical representation of a database
    # in the sense that the produced string
    # can be unambiguously transformed back
    # into a database using #literals
    
    def self.canonical_str s
        tmp = s.gsub(/"/, '\\"').gsub(/'/, "\\'").gsub(/\\/, "\\\\")
        if [',', ':', ' ', "\n"].any? {|x| s.include? x}
          tmp = '"' + tmp + '"'
        end
        tmp 
    end

    def self.canonical db
      db.map {|l|
        containers.map{|x| 
          canonical_str x
        }.cs.join(", ") + ": " + (canonical_str l)
      } 
    end
  end
end

class String
  
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
