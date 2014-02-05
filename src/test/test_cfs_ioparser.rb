require 'test/unit' 
require '../cfs_ioparser.rb'

class TestCFSIOParser < Test::Unit::TestCase
  
  def test_simple

    db = CFS::Database.by_hash({
      "l" => ([["t"]])
    })

    assert_db db

    return

    db = CFS::Database.by_hash ({
      "l1" => ([
        ["tag1"],
        ["tag2"],
        ["tag3", "subtag31"],
        ["with quotes", 'sub "test"'],
       ]),
       "l2" => ([
        ["another", "tag"]
       ])
    })

    # TODO
    # some issue with Set#== 
    assert_db db
  end

  def assert_db db
    r = CFS::IOParser.read(CFS::IOParser.write(db))
    assert_equal(db, r)
  end
end
