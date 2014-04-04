require './cfs.rb'
require './cfs_parser.rb'
require 'test/unit'

class TestCFSContainer < Test::Unit::TestCase
  def test_minimize
    s = [
      ["(a:b:c:d,a:b:c:e)", "a:b:c:(d,e)"],
      ["(a:b:c:d,a:b:c:e,(k,l))", "((a:b:c:(d,e)),(k,l))"],
      ["(a:b:c_1:d,a:b:c_2:e)", "a:b:(c_1:d,c_2:e)"],
      ["(a:b,a:b:c)", "a:b:c"],
      ["(a:(b:c,k:l),a:(b:e,k:m))", "(a:(b:c,k:l),a:(b:e,k:m))"]

      # for the following two, note:
      # (a:b, c:d:(e,f))
      # = (a:b, (c:d:e, c:d:f))
      # (!) = ((a:b, c:d:e), (a:b, c:d:f))
      # thus, they need another distributive law!
      
      # ["((a:b,c:d:e),(a:b,c:d:f))", "(a:b,c:d:(e,f))"],
      # ["((a:b,c:d:e,c:d:z),(a:b,c:d:f))", "(a:b,c:d:((e,z),f))"]
    ]

    s.each{|k|
      r1 = CFS::Parser.parse_line k[0]
      r2 = CFS::Parser.parse_line k[1]

      r1 = r1.minimize

      puts r2.to_s
      puts r1.to_s

      assert_equal(r2, r1)
    }
    
  end
end
