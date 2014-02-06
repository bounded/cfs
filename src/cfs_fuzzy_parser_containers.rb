require_relative 'cfs.rb'

module CFS
  class FuzzyParser

    def containers s
      CFS::debug "\n### FuzzyParser.containers #{s}"

      ks = CFS::FuzzyParser.tokenize_containers s
      CFS::debug "Parsed: #{ks.inspect}"

      cs = Set.new
      c = CFS::Container.new 

      i = 0

      while i < ks.length
        # create new container by adding another keyword
        cn = CFS::Container.new (c + [ks[i]])

        # check whether this matches an existing container
        CFS::debug "match #{cn.inspect}"
        ms = CFS::Container.fuzzy_match_c cn, @info[:cs]
        CFS::debug "result: #{ms}"

        if ms.empty?
          # CASE 1: No matches
          if cn.length == 1
            # CASE 1.1: Only one keyword $kw
            
            # CASE 1.1.1: check for a container $c1 ... $cn $kw
            sup_cs = CFS::Container.fuzzy_super_c ks[i], @info[:cs]
            CFS::debug "Possible super containers: #{sup_cs}."
            
            if sup_cs.length == 1
              CFS::debug "Use container #{sup_cs[0]}." 
              c = sup_cs[0]
            else
              # CASE 1.1.2: create PseudoContainer for $kw
              CFS::debug "Ambiguous result. Create PseudoContainer #{ks[i]}." 
              ps_c = CFS::PseudoContainer.new([ks[i]]) 
              cs << ps_c
              CFS::debug "Add #{ps_c.inspect}"
              c = []
            end
          else
            # CASE 1.2: backtrack and use the last successful container
            cs << c
            CFS::debug "add #{c.inspect}"
            c = []
            # process the current keyword again
            i -= 1
          end
        elsif ms.length > 1
          # CASE 2: More than one match
          # Inform the user and take the best match
          CFS::debug "Ambiguous input #{ks[i]}."
          CFS::debug "Choose #{ms[0].inspect}."
          c = ms[0]
        else
          # CASE 3: One match
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

    def self.tokenize_containers s
      s.materialize_quotes! /\s/
      r = []
      acc = ""
      escape_next = false

      s.each_char {|c|
        if escape_next
          escape_next = false
          acc << c
          next
        end

        if c == '\\'
          escape_next = true
          next
        end

        if c =~ /\s/
          r << acc unless acc.empty?
          acc = ""
        else
          acc << c
        end
      }

      r << acc unless acc.empty?
      r
    end
  end
end
