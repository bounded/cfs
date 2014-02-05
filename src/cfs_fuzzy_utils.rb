module CFS
  class Container

    def fuzzy_implies?(o)
      CFS::debug "#{self}.fuzzy_implies? #{o}"

      return true if implies?(o)
      return false unless depth >= o.depth

      i = 0
      i += 1 while self[i] == o[i]

      until i == self.length
        break unless o[i]

        is_prefix = self[i].fuzzy_prefix? o[i]
        is_fuzzy = self[i].fuzzy_eql? o[i]
        unless is_prefix or is_fuzzy
          return false
        end
        i += 1
      end

      true
    end

    # input: "fo", [["tag", "foo", "bar"],["tag2, "foo"],["tag3", "bla"]]
    # output: [["tag", "foo"],["tag2, "foo"]]
    def self.fuzzy_super_c c_str, cs
      r = []
      cs.each {|x|
        x.each_with_index {|x_i, i|
          if x_i.fuzzy_eql? c_str or x_i.fuzzy_prefix? c_str
            r << x[0..i]
          end
        }
      }
      r
    end

    # input: ["tg1", "bl"], [["tag1", "bla"]]
    # output: ["tag1", "bla"]
    def self.fuzzy_match_c c, cs
      return [c] if cs.any? {|x| x.implies? c}
      cs.select{|x| x.fuzzy_implies? c}
    end
  end
end

class String
  # TODO write more sophisticated distance function
  
  def fuzzy_eql?(o)
    if self == o
      true
    else
      # first char must always be equal
      return false if self[0] != o[0]

      # heuristic for difference between letter frequency 
      h1 = self.char_freq
      h2 = o.char_freq

      num = 0
      (h1.keys + h2.keys).each {|k|
        f1 = h1[k] || 0
        f2 = h2[k] || 0
        num += (f1 - f2).abs
      }
      num <= 2
    end
  end

  def fuzzy_prefix?(o)
    index(o) == 0 && (o.length >= 3)
  end

  def char_freq
    h = {}
    each_char {|c|
      if h[c]
        h[c] += 1
      else
        h[c] = 1
      end
    }
    h
  end
end
