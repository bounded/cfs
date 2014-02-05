require 'test/unit'
require '../cfs.rb'

class TestCFSFuzzyParserContainers < Test::Unit::TestCase

  def test_db_equal
    db1 = CFS::Database.by_hash ({
      "l1" => ([ ["tag1"], ["tag2"] ]),
      "l2" => ([ ["test"] ])
    })

    db2 = CFS::Database.by_hash ({
      "l2" => ([ ["test"] ]), 
      "l1" => ([ ["tag2"], ["tag1"] ]) 
    })

    assert_equal db1, db2

    l = CFS::Literal.new "l1"
    l.containers = [CFS::Container.new(["tag1"]), CFS::Container.new(["tag2"])]
    assert db2.include? l
    assert db1.include? l
  end
end
