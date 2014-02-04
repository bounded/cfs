require 'test/unit'
require '../cfs_fuzzy_utils.rb'

class TestCFSFuzzyUtils < Test::Unit::TestCase
  def test_fuzzy_eql?
    t = [
      ["tg1", "tag1"],
      ["marmalade", "mamalade"],
      ["foo", "foo"]
    ]

    t_n = [
      ["foo", "bar"],
      ["test", "es"]
    ]
    
    t.each {|x|
      assert(x[0].fuzzy_eql?(x[1]), "#{x[0]}.fuzzy_eql? #{x[1]} != true")
    }

    t_n.each {|x|
      assert(!x[0].fuzzy_eql?(x[1]), "#{x[0]}.fuzzy_eql? #{x[1]} == true")
    }
  end
end
