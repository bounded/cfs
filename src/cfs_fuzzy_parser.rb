module CFS

  class FuzzyParser
    def initialize db
      @db = db
      process_db
    end 

    def process_db
      cs = []
      @db.each { |l|
        cs = cs.concat l.container
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

    # returns: set of Container
    def query str
      ks = str.split
      i = 0
      c = []
      cs = Set.new

      until i == ks.length
        cn = CFS::Container.new (c + [ks[i]])

        CFS::debug "match #{cn.inspect}"
        ms = fuzzy_match_c cn
        CFS::debug "result: #{ms}"

        if ms.empty?
          if cn.length == 1
            sup_cs = fuzzy_super_c ks[i]
            CFS::debug "Possible super containers: #{sup_cs}."
            
            if sup_cs.length == 1
              CFS::debug "Use container #{sup_cs[0]}." 
              c = sup_cs[0]
            else
              CFS::debug "Ambiguous result. Create PseudoContainer #{ks[i]}." 
              ps_c = CFS::PseudoContainer.new([ks[i]]) 
              # TODO
              # use fuzzy_include?
              cs <<  ps_c
              CFS::debug "Add #{ps_c.inspect}"
              c = []
            end
          else
            cs << c
            CFS::debug "add #{c.inspect}"
            c = []
            # process the current keyword again
            i -= 1
          end
        elsif ms.length > 1
          CFS::debug "Ambiguous input #{ks[i]}."
          CFS::debug "Choose #{ms[0].inspect}."
          c = ms[0]
        else
          c = ms[0]
        end

        i += 1
      end

      unless c.empty?
        cs << c 
        CFS::debug "add #{c.inspect}"
      end

      cs
    end

    def fuzzy_super_c c_str
      cs = []
      @info[:cs].each {|x|
        x.each_with_index {|x_i, i|
          if x_i.fuzzy_eql? c_str
            cs << x[0..i]
          end
        }
      }
      cs
    end

    def fuzzy_match_c c
      return [c] if @info[:cs].any? {|x| x.implies? c}
      @info[:cs].select{|x| x.fuzzy_implies? c}
      # TODO sort
    end
  end

  class Container
    def fuzzy_implies?(o)
      CFS::debug "#{self.inspect}.fuzzy_implies? #{o.inspect}"
      return true if implies?(o)
      return false unless depth >= o.depth

      i = 0
      i += 1 while self[i] == o[i]

      until i == self.length
        break unless o[i]

        is_prefix = self[i].index(o[i]) == 0
        is_fuzzy = self[i].fuzzy_eql? o[i]
        unless is_prefix or is_fuzzy
          return false
        end
        i += 1
      end

      true
    end
  end
end

class String
  def fuzzy_eql?(o)
    if self == o
      true
    else
      return false if self[0] != o[0]

      # difference between letter frequency at most 1
      h1 = self.char_freq
      h2 = o.char_freq

      (h1.keys + h2.keys).each {|k|
        f1 = h1[k] || 0
        f2 = h2[k] || 0
        return false if ((f1 - f2).abs > 1)
      }
      true
    end
  end

  def fuzzy_include?(o)
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
