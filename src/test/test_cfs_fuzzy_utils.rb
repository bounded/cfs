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
      ["test", "es"],
      ["exam", "emacs"]
    ]
    
    t.each {|x|
      assert(x[0].fuzzy_eql?(x[1]), "#{x[0]}.fuzzy_eql? #{x[1]} != true")
    }

    t_n.each {|x|
      assert(!x[0].fuzzy_eql?(x[1]), "#{x[0]}.fuzzy_eql? #{x[1]} == true")
    }
  end

  def test_fuzzy_prefix?
    assert("subset123".fuzzy_prefix? "sub")
  end

  def test_fuzzy_super_c
    input = ["sub", [["tag1", "subset12"]]]
    output = CFS::Container.fuzzy_super_c *input
    assert_equal [["tag1", "subset12"]], output
  end
end
