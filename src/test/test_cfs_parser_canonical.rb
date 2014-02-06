require 'test/unit'
require '../cfs_fuzzy_parser.rb'

class TestCFSFuzzyParserContainers < Test::Unit::TestCase
  def setup
    @db = CFS::Database.by_hash ({
      "l1/ l2\n multiline" => ([
        ["tag1"],
        ["tag2"],
        ["tag3", "subtag31"],
        ["with quotes", 'sub "test"'],
       ]),

      "t\nt:\nb" => []
    })

    @parser = CFS::FuzzyParser.new @db
  end

  def test_1
    str = CFS::FuzzyParser.canonical(@db)
    assert_equal(@db, @parser.literals(str))
  end
end
