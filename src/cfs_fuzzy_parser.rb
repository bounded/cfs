require_relative 'cfs.rb'
require_relative 'cfs_fuzzy_utils.rb'

module CFS
  class FuzzyParser
    def initialize db
      @db = db
      process_db
    end 

    def process_db
      cs = []
      @db.each { |l|
        cs += l.container
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

    def containers s

    end

    def literals s

    end


    def self.tokenize_XXX str
      tmp = []
      acc = ""
      in_quotes = false
      escape_next = false
      in_literal = false
      c = nil
      i = 0

      if str[str.length-1] != "\n"
        str += "\n"
      end

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
          if !in_quotes && !in_literal
            tmp << acc if acc != ""
            acc = ""
            tmp << :comma
          else
            acc += c
          end
        when ':'
          if in_quotes or in_literal
            acc += c
          else
            tmp << acc if acc != ""
            acc = ""
            tmp << :colon
          end
        when '"'
          in_quotes = !in_quotes
        when /[ \t]/
          if in_quotes or in_literal
            acc += c
          else
            if acc != ""
              if tmp.last == :colon
                acc += c
              else
                tmp << acc
                acc = ""
              end
            end
          end
        when '\\'
          escape_next = true
        when "\n"
          if in_quotes
            acc += c
          else
            # if the current line is non-empty
            if ((!tmp.empty? && tmp.last != :break) or acc != "") 
              
              # STEP 1: Check if the current line was unnecessarily parsed
              # get current line
              prev_break = tmp.rindex :break
              if prev_break != nil
                cl = tmp[(prev_break + 1)..(tmp.length-1)]
              else
                cl = tmp
              end

              # if the parsed objects should not have been parsed
              if not cl.empty? and not cl.include? :colon
                tmp.pop cl.length
                last_nl = i-1
                loop do
                  if str[last_nl] == "\n"
                    acc = str[(last_nl+1)..(i-1)]
                    break
                  elsif last_nl == 0
                    acc = str[0..(i-1)]
                    break
                  end
                  last_nl -= 1 
                end
                in_literal = true
              end

              # STEP 2: check the next lines
              next_char = str.index /[^ \t\n]/, (i+1)

              # if only whitespace follows
              if next_char == nil
                tmp << acc if acc != ""
                # no break after the last literal
                return tmp
              else
                if str[(i+1)..(next_char-1)].include? "\n"
                  # separation between two literals
                  # such as:
                  # a, b: literal1
                  #
                  # literal2
                  tmp << acc if acc != ""
                  tmp << :break

                  acc = ""
                  in_literal = false
                else
                  # no separator
                  # e.g.:
                  # "a: start\n end"
                  if in_literal
                    acc += "\n"
                  else 
                    # e.g.:
                    # "a: \n start and end"
                    in_literal = true
                  end
                end
              end
            end
          end
        else
          acc += c
          if tmp.last == :colon
            in_literal = true
          end
        end

        i += 1
      end

      if acc != ""
        tmp << acc 
      end

      tmp
    end
  end
end
