require 'test/unit'
require '../cfs.rb'
require '../cfs_parser.rb'
require '../cfs_fuzzy_parser.rb'

class TestCFSFuzzyParser < Test::Unit::TestCase
  def setup
    @db = CFS::Database.new
    [
      "tag1, tag2, tag3 subtag31: l1"
    ].each{ |a| 
      @db.add (CFS::Parser::parse_l a)
    }
    @parser = CFS::FuzzyParser.new @db
  end

  def test_1
    # exact matches
    assert_query_parser([["tag1"]], "tag1")
    assert_query_parser([["tag1"], ["tag2"]], "tag1 tag2")
    assert_query_parser([["tag3", "subtag31"], ["tag1"], ["tag2"]], "tag1 tag2 tag3 subtag31")

    # subset and fuzzy match and no match
    assert_query_parser([["tag3", "subtag31"], ["tag1"], ["tag2"]], "tg1 tag2 tag3 sub")

    # pseudo containers
    assert_query_parser([["foo1"], ["foo2"]], "foo1 foo2")

    # automatically find super containers
    assert_query_parser([["tag3", "subtag31"]], "sub")
    
  end

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

  def assert_query_parser exp, input
    puts "## Input: #{input}"
    assert_equal(Set.new(exp.map{|x| CFS::Container.new x}), @parser.query(input))
  end

end
