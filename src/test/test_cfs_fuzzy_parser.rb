require 'test/unit'
require '../cfs_fuzzy_parser.rb'

class TestCFSFuzzyParserContainers < Test::Unit::TestCase
  def setup
    @db = CFS::Database.by_hash ({
      "l1" => ([
        ["tag1"],
        ["tag2"],
        ["tag3", "subtag31"],
        ["with quotes", 'sub "test"'],
       ])
    })

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
    assert_containers([["tag3", "subtag31"]], "subtag")

    # with quotes and escape
    str = 'no\\ match "pseudo contain"er "with quotes" "sub \\"test'
    arr = [["no match"], ["pseudo container"], ["with quotes", "sub \"test\""]]
    assert_containers( arr, str )  
  end

  def assert_containers exp, input
    assert_equal(Set.new(exp), @parser.containers(input))
  end

end

class TestCFSFuzzyParserLiterals < Test::Unit::TestCase

  def setup
    @parser = CFS::FuzzyParser.new (CFS::Database.new [])
  end

  def test_simple
    str = <<END
tag1, tag2:
Some literal.

tag2, tag3:
Some literal.

tag4:
Another one.
END
    db = {
      "Some literal." => [
        ["tag1"],
        ["tag2"],
        ["tag3"]
    ],
      "Another one." => [
        ["tag4"]
    ]
    }
    assert_literals db, str
end

  def assert_literals exp, input
    assert_equal(CFS::Database.by_hash(exp), @parser.literals(input))
  end
end

class TestCFSFuzzyParserCanonical < Test::Unit::TestCase

  def test_1
    db = CFS::Database.by_hash ({
      "very long\nliteral" => ([
        ["tag1"],
        ["tag2"],
        ["tag3", "subtag31"],
        ["with quotes", 'sub "test"'],
       ])
    })

    str = <<END
tag1, tag2, tag3 subtag31, "with quotes" "sub \\"test\\"": 
very long
literal
END
    str = str[0..-2]
    out = (CFS::FuzzyParser.canonical db)

    puts out
    assert_equal str, out
  end
end
