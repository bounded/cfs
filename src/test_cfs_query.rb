require 'test/unit'
require './cfs_query.rb'

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

  def _test_2
    person = CFS::Parser.parse_line "person:(name:Max1, tel:1132413)"
    todo = CFS::Parser.parse_line "todo:(01/01/14, Do laundry)"

    person_g = CFS::Parser.parse_line "person"
    book_g = CFS::Parser.parse_line "book"

    assert_equal((person < person_g), true)
    assert_equal((person < book_g), false)

    assert_equal((todo < person_g), false)
  end

  def test_1
     r = CFS::Query.strict "person", @db
    db_s = 
<<HERE
person:(name:Max1, tel:1132413)
person:(name:Max2, tel:2132413)
HERE
     assert_equal r, p_d(db_s) 
    
     r = CFS::Query.strict "book:The Doomed", @db
    db_s = 
<<HERE
book:The Doomed:chapter:5, note:Rewrite
book:The Doomed:chapter:3, note:Publish
HERE
     assert_equal r, p_d(db_s) 
     
     r = CFS::Query.strict "book:The Doomed:chapter:5", @db
    db_s = 
<<HERE
book:The Doomed:chapter:5, note:Rewrite
HERE
     assert_equal r, p_d(db_s) 

     r = CFS::Query.strict "note", @db
    db_s = 
<<HERE
book:The Doomed:chapter:5, note:Rewrite
book:The Doomed:chapter:3, note:Publish
HERE
     assert_equal r, p_d(db_s) 

     r = CFS::Query.strict "todo", @db
    db_s = 
<<HERE
todo:(01/01/14, Do laundry)
todo:(01/02/14, Go shopping)
todo:(01/03/14, Prepare dinner, Do some other stuff)
todo:(01/03/14, Even more stuff)
HERE
    assert_equal r, p_d(db_s) 

    r = CFS::Query.strict "todo:(01/03/14, Prepare dinner)", @db
    db_s = 
<<HERE
todo:(01/03/14, Prepare dinner, Do some other stuff)
HERE
     assert_equal r, p_d(db_s) 
  end

  def test_complex
     r = CFS::Query.strict "todo:01/02/14", @db
    db_s = 
<<HERE
todo:(01/02/14, Go shopping)
HERE
     assert_equal r, p_d(db_s) 
  end

  def p_d db_str
    CFS::Parser.parse db_str
  end
end

=begin
=end
