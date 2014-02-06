require_relative 'cfs_fuzzy_parser.rb'

module CFS
  class FuzzyParser

    def literals s
      tok = tokenize_literals s
      CFS::debug "Tokenized: #{tok}"
      db = CFS::Database.new
      tok.each {|t|
        l = CFS::Literal.new t.pop
        t.pop

        cs = t.split(:comma).map {|arr|
          CFS::Container.new arr
        }
        l.containers = cs
        db.add l
      }  
      db
    end

    # output: [["tag1", :comma, "tag2", :colon, "literal"]]
    def tokenize_literals s
      CFS::debug "Tokenize: #{s}"
      s.materialize_quotes! /[: ,]/
      r = []
      tmp = s.split("\n")

      until tmp.empty?
        k = [tmp.shift]
        i = tmp.index{|x| x =~ /[^\\]:/} || tmp.length
        k = k.concat tmp.shift(i) 
        r << k.join("\n")
      end

      CFS::debug "Subresult: #{r}"

      r.map {|x|

        x_r = []
        acc = ""
        escape_next = false
        in_literal = false

        x.each_char {|c|
          if escape_next
            acc << c
            escape_next = false
            next
          end

          case c
          when '\\'
            escape_next = true
          when /\s/
            if in_literal
              acc << c unless acc.empty?
            else
              x_r << acc unless acc.empty?
              acc = ""
            end
          when ','
            if in_literal
              acc << ','
            else
              x_r << acc unless acc.empty?
              acc = ""
              x_r << :comma
            end
          when ':'
            in_literal = true
            x_r << acc unless acc.empty?
            acc = ""
            x_r << :colon
          else
            acc << c
          end
        }

        x_r << acc.chomp
        x_r

      } 
    end
  end
end
