module CFS

  class FuzzyParser

    def parse_db str
       
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

  end

end

