module CFS
  class FuzzyParser
    def self.tokenize_literals str
      #
      # STAGE 1
      #

      str.strip!
     
      tmp = []
      acc = ""
      in_quotes = false
      escape_next = false
      after_colon = false

      c = nil
      i = 0

      while i < str.length
        c = str[i]

        if escape_next
          acc += c
          escape_next = false
        else
          case c
          when ':'
            is_end = str[(i+1)..-1].strip == "" or acc.empty?
            if in_quotes or after_colon or is_end
              acc += c
            else
              tmp << acc
              acc = ""
              tmp << :colon
              after_colon = true
            end
          when '"'
            in_quotes = !in_quotes
            acc += c
          when '\\'
            escape_next = true
            acc += c unless after_colon
          when /[ \t]/
            acc += c unless acc.empty?
          when "\n"
            if in_quotes
              if tmp.last != :colon && !acc.empty?
                # e.g.
                # li"teral with"quotes
                tmp << acc
                tmp << :break
                acc = ""
                in_quotes = false
              else
                acc += c
              end
            else
              # check the next lines
              next_char = str.index /[^ \t\n]/, (i+1)

              if next_char 
                if str[(i+1)..(next_char-1)].include? "\n"
                  # a, b: literal1
                  #
                  # literal2
                  tmp << acc unless acc.empty?
                  tmp << :break unless tmp.last == :break
                  acc = ""
                  #i = next_char-1
                  after_colon = false
                else
                  if !acc.empty?
                    # a: start
                    # end
                    acc += "\n"
                  else 
                    # a: 
                    # start and end
                  end
                end
              else
                tmp << acc unless acc.empty?
                acc = ""
                break
              end
            end
          else
            acc += c
          end
        end
        i += 1
      end

      tmp << acc unless acc.empty?

      #
      # STAGE 2
      #

      res = []
      return res if tmp.empty?

      split_by_break(tmp).each {|bl|
        case bl.length
        when 1
          # literal
          res << bl[0].strip
        when 2
          # a, b c:
          res += tokenize_literals_cs(bl[0])
          res << :colon
        when 3
          # a, b c: literal
          res += tokenize_literals_cs(bl[0]) 
          res << :colon
          res << bl[2].strip
        end
        res << :break
      }
      res.pop

      res
    end

    def self.split_by_break arr
      i = arr.index :break
      if i == nil
        [arr]
      else
        [arr[0..(i-1)]] + (split_by_break arr[(i+1)..(arr.length-1)])
      end
    end

    def self.tokenize_literals_cs str
      str.strip!

      tmp = []
      acc = ""
      in_quotes = false
      escape_next = false

      c = nil
      i = 0

      while i < str.length
        c = str[i]

        if escape_next
          acc += c
          escape_next = false
        else
          case c
          when ','
            if in_quotes 
              acc += c
            elsif (!tmp.empty? && tmp.last != :comma) || (!acc.empty?)
              tmp << acc unless acc.empty?
              tmp << :comma
              acc = ""
            end
          when /[ \t]/
            if in_quotes
              acc += c
            elsif !acc.empty?
              tmp << acc
              acc = ""
            end
          when '"'
            in_quotes = !in_quotes
          when '\\'
            escape_next = true
          else
            acc += c
          end
        end
        i += 1
      end

      tmp << acc unless acc.empty?

      if tmp.last == :comma
        tmp.pop
      end
      tmp
    end

    def self.tokenize_containers str
      tmp = []
      escape_next = false
      in_quotes = false

      i = 0
      c = nil
      acc = ""

      while i < str.length
        c = str[i]

        if escape_next 
          acc += c
          escape_next = false
        else
          case c
          when '"'
            in_quotes = !in_quotes
          when /[\s]/
            if in_quotes
              acc += c
            else
              unless acc.empty?
                tmp << acc
                acc = ""
              end
            end
          when '\\'
            escape_next = true
          else
            acc += c
          end
        end

        i += 1
      end

      unless acc.empty?
        tmp << acc
        acc = ""
      end

      tmp
    end

  end
end
