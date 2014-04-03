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

  def test_1
    # r = CFS::Query.strict "person", @db
    
    # r = CFS::Query.strict "book:The Doomed", @db
     r = CFS::Query.strict "book:The Doomed:chapter:5", @db
     r = CFS::Query.strict "note", @db
     r = CFS::Query.strict "todo", @db
     r = CFS::Query.strict "todo:01/02/14", @db
    r = CFS::Query.strict "todo:(01/03/14, Prepare dinner)", @db
  end
end

=begin
=end
