require 'test/unit'
require './cfs_fuzzy_query.rb'

class TestCFSQuery < Test::Unit::TestCase

  def setup
    db_s = 
<<HERE
person:(name:Max1, tel:1132413)
person:(name:Max2, tel:2132413)
book:The Doomed:chapter:5, note:Rewrite
book:The Doomed:chapter:3, note:Publish
todo:(01/01/14, Do laundry)
todo:(01/02/14, Go shopping)
todo:(01/03/14, Prepare dinner, Do some other stuff)
todo:(01/03/14, Even more stuff)
HERE
    @db = (CFS::Parser.parse db_s).minimize
  end

  def test_generate_queries
    r = CFS::Query.generate_queries("book note", @db)
    debug_r r

    r = CFS::Query.generate_queries "todo 01/03/14", @db
    debug_r r
  end

  def test_generate_variations
     c = CFS::Parser.parse_line "a:b"
     r = CFS::Query.generate_variations c, "k" 
     e = p_ls ["a:(b,k)","a:b:k"]

     assert_equal r, e

     c = CFS::Container.new
     r = CFS::Query.generate_variations c, "k" 
     # 1st: k
     # 2nd: (k) [needed for recursion later]
     e = [c('k'), c(nil, [c('k')])]

     assert_equal r, e

     c = CFS::Parser.parse_line "(a,b)"
     r = CFS::Query.generate_variations c, "k" 
     e = p_ls ["k:(a,b)","(a,b,k)","(a:k,b)","(a,b:k)"]

     assert_equal r, e
  end

  def p_ls ls
    ls.map{|x| 
      CFS::Parser.parse_line x
    }
  end

  def debug_r r
    r.each {|x|
      puts x.to_pretty_s
    }
  end

  def c a=nil, b=Set.new
    if b.is_a? Array
      tmp = Set.new b
      b = tmp
    end
    CFS::Container.new a, b
  end

end
