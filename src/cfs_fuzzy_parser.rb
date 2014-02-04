require_relative 'cfs.rb'
require_relative 'cfs_fuzzy_tokenizer.rb'
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
      CFS::debug "\n### FuzzyParser.containers #{s}"

      cs = Set.new
      c = CFS::Container.new 

      ks = CFS::FuzzyParser.tokenize_containers s
      CFS::debug "Tokenized: #{ks.inspect}"
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
              # TODO
              # use fuzzy_include?
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

    # returns CFS::Database
    def literals s
      tks = CFS::FuzzyParser.tokenize_literals s
      r = CFS::Database.new

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
  end
end
