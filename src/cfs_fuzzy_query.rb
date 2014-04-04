require './cfs_query.rb'

module CFS
  class Query
    def self.fuzzy_query str, db
      qs = generate_queries str, db
      r = CFS::Container.new

      db.children.each {|x|
        if qs.any?{|q| q > x}
          r.add x
        end
      }
      r
    end

    #
    # The purpose of this part is to guess the structure
    # of the passed keywords.
    # 
    
    def self.generate_queries str, db
      str.strip!
      l = str.split /[\s]+/
      gq_help l, CFS::Container.new, db
    end

    # kws = keywords that are still available to create contianer
    # c = the current container 
    def self.gq_help kws, c, db
      if kws.empty?
        [c]
      else
        r = []
        kws.each_with_index {|k,i|
          var = (generate_variations c, k)
          var.each {|v|
            unless (query v, db).empty?
              kws_rem = kws.dup
              kws_rem.delete_at i

              r += (gq_help kws_rem, v, db)
            end
          }  
        } 
        r
      end
    end

    # create all variations of c and k
    # i.e ways of combining c and k
    def self.generate_variations c, k
      var = []
      if c.name == nil
        c_ = c.dup
        c_.name = k
        var << c_
      end

      c_ = c.dup
      c_.add (CFS::Container.new k)
      var << c_

      c.children.each_with_index {|c_i, i|
        (generate_variations c_i, k).each {|v_i|
          c_ = c.dup
          c_.children.delete c_i
          c_.add v_i
          var << c_
        }
      }

      var
    end
  end
end
