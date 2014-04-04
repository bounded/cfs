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
      (gq_help l, CFS::Container.new, db).uniq
    end

    # kws = keywords that are still available to create container
    # c = the current container 
    def self.gq_help kws, c, db
      if kws.empty?
       [c]
      else
        r = []
        kws.each_with_index {|k,i|
          var = (generate_variations c, k)
          var.each {|v|
            if !(query v, db).empty?
              kws_rem = kws.dup
              kws_rem.delete_at i

              r += (gq_help kws_rem, v, db)
            end
          }  
        } 

        if r.empty?

        end

        # used for typos or
        # if intermediary containers were skipped

        # get all containers cs_i that are more specialized than c
        # for each cs_i:
        # find most general specializations a_i
        #
        # for example:
        # c = (x_1, x_2)
        # cs_i = (x_1:y_1:z_1, x_2:y_2:z_2)
        # => a_1 = (x_1:y_1, x_2)
        # => a_2 = (x_1, x_2:y_2)
        #
        # added literals != keywords !
        #
        # if the added literals are similar to a keyword remove the
        # keyword from kws
        #
        # recusive step
        #
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

    # e.g.
    # c1 = (x1, x2)
    # c2 = (x1:y1:z1, x2:y2:z2, k:l)
    #
    # c1 = k
    # c2 = k:l:m
    #
    # c1 = a
    # c2 = (a:a1, b:b1)
    #
    # NOT c1 = (a,b); c2 = b:b2
    #
    # result:
    # [(x1:y1, x2), (x1, x2:y2)]
    def self.all_mgs_of c1, c2
      if c1.name == nil and c2.name == nil
        c2.children.each {|c2_i|
          # exists c1_i such that c1_i > c2_i
          # case 1: >
          # t = all_mgs_of c1_i, c2_i
          # for each t_i , replace c1_i by t_i
          #
          # exists c1_i such that c1_i == c2_i
          # do nothing
          #
          # for all c1_i: uncomparable (like with k:l)     
          # add only the most general version
        } 
      elsif c1.name == c2.name
        # most general version of children of c2
      elsif c1.name and c2.name == nil
        # get c2_i from c2's children such that c1 > c2_i 
        # get msg of them
        
        # then, create the most general unnamed container
        # => (a,b)
      else
        # Error
        raise Error
      end 
    end
  end
end
