require 'test/unit'
require '../cfs_fuzzy_parser.rb'

class TestCFSFuzzyParserContainers < Test::Unit::TestCase
  def setup
    @db = CFS::Database.new
    l = CFS::Literal.new "l1"
    l.container = [
      CFS::Container.new(["tag1"]),
      CFS::Container.new(["tag2"]),
      CFS::Container.new(["tag3", "subtag31"]),
      CFS::Container.new(["with quotes", "sub \"test\""])
    ]
    @db.add l

    @parser = CFS::FuzzyParser.new @db
  end

  def test_containers
    # exact matches
    assert_containers([["tag1"]], "tag1")
    assert_containers([["tag1"], ["tag2"]], "tag1 tag2")
    assert_containers([["tag3", "subtag31"], ["tag1"], ["tag2"]], "tag1 tag2 tag3 subtag31")

    # subset and fuzzy match and no match
    assert_containers([["tag3", "subtag31"], ["tag1"], ["tag2"]], "tg1 tag2 tag3 sub")

    # pseudo containers
    assert_containers([["foo1"], ["foo2"]], "foo1 foo2")

    # automatically find super containers
    assert_containers([["tag3", "subtag31"]], "sub")

    # with quotes and escape
    str = 'no\\ match "pseudo contain"er "with quotes" "s \\"tst'
    arr = [["no match"], ["pseudo container"], ["with quotes", "sub \"test\""]]
    assert_containers( arr, str )  
    
  end

  def assert_containers exp, input
    assert_equal(Set.new(exp), @parser.containers(input))
  end

end
