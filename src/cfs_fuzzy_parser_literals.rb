require_relative 'cfs.rb'

module CFS
  class FuzzyParser

    def literals s
      tok = CFS::FuzzyParser.tokenize_literals s
      CFS::debug "Tokenized: #{tok}"
      db = CFS::Database.new

      (tok.split :break).each {|t|
        if t.include? :colon
          l = CFS::Literal.new t.pop
          # remove :colon
          t.pop

          cs = t.split(:comma).map {|arr|
            CFS::Container.new arr
          }
          l.containers = cs
          CFS::debug "Add literal #{l.inspect}"
        else
          unless t.empty?
            l = CFS::Literal.new t[0]
          end
        end
        if l
          CFS::debug "Add literal #{l.inspect}"
          db.add l
        end
      }  
      db
    end

    # output: ["tag1", :comma, "tag2", :colon, "literal"]
    def self.tokenize_literals s
      CFS::debug "Tokenize: #{s}"
      s.strip!
      s.materialize_quotes! /[: ,]/
      r = []
      tmp = s.split("\n")

      until tmp.empty?
        k = [tmp.shift]
        i = tmp.index{|x| x =~ /[^\\]:|\A:/} || tmp.length
        k = k.concat tmp.shift(i) 
        r << k.join("\n")
      end

      CFS::debug "Subresult: #{r}"
      tmp = r
      r = []

      tmp.each {|x|

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
              r << acc unless acc.empty?
              acc = ""
            end
          when ','
            if in_literal
              acc << ','
            else
              if !acc.empty? 
                r << acc 
                acc = ""
              end
              if (!r.empty? && r.last != :comma)
                r << :comma
              end
            end
          when ':'
            if in_literal
              acc << ':'
            else
              in_literal = true
              r << acc unless acc.empty?
              r.pop if r.last == :comma
              acc = ""
              r << :colon
            end
          else
            acc << c
          end
        }

        acc.strip!
        r << acc unless acc.empty?
        r << :break unless r.empty?

      }

      # remove :break
      r.pop

      if !r.include? :colon
        s.empty? ? [] : [s]
      else
        r
      end

    end
  end
end
