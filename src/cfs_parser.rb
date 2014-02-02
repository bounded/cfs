module CFS
  module Parser
    # expects:
    # a a1, b b1 b2, c, d, e: literal
    # returns CFS::Literal
    #
    # you can escape blank, comma and colon by using \
    # alternatively, put them into quotes
    def self.parse_l str

      t = CFS::Tokenizer::tokenize(str)

      if t.length == 1
        return (CFS::Literal.new t[0])
      end
      
      if (!t.include? :colon) && (!t.include? :comma)
        return (CFS::Literal.new str.strip)
      end

      cs = parse_cs str

      l = CFS::Literal.new t.last
      l.container = cs
      l
    end

    # expects:
    # a a1, b b1 b2, c, d, e
    def self.parse_cs str
      t = CFS::Tokenizer::tokenize str

      cs = []
      ci = []
      t.each {|x|
        if x == :comma
          cs << (CFS::Container.new ci) unless ci.empty?
          ci = []
        elsif x == :colon
          break
        else
          ci << x
        end
      }
      cs << (CFS::Container.new ci) unless ci.empty?
      cs
    end
  end

  module Tokenizer
    def self.tokenize str

      tmp = []
      acc = ""
      in_quotes = false
      escape_next = false
      in_literal = false
      after_colon = false
      c = nil
      i = 0

      while i < str.length
        c = str[i]

        if escape_next
          acc += c
          escape_next = false
          i += 1
          next
        end

        case c
        when ','
          unless in_quotes
            tmp << acc if acc != ""
            acc = ""
            tmp << :comma
          else
            acc += c
          end
        when ':'
          if in_quotes or after_colon
            acc += c
          else
            tmp << acc if acc != ""
            acc = ""
            tmp << :colon
            in_literal = true
            after_colon = true
          end
        when '"'
          in_quotes = !in_quotes
        when ' '
          unless in_quotes
            if acc != ""
              if tmp.last == :colon
                acc += c
              else
                tmp << acc
                acc = ""
              end
            end
          else
            acc += c
          end
        when '\\'
          escape_next = true
        else
          acc += c
        end

        i += 1
      end

      if acc != ""
        if tmp.empty?
          tmp = [acc]
        else
          tmp << acc
        end
      end

      raise ArgumentError if in_quotes
      tmp
    end

  end
end
