require 'test/unit'
require '../cfs_parser.rb'
require '../cfs.rb'

class TestCFS < Test::Unit::TestCase
  
  def setup
    @l = [
      'novel, ch 5: some text snippet.',
      'vim: learn new keystrokes',
      'dinner, date 01/14/99: buy the new ingredient',
      'buy, gadgets: www.xyz.com',
      'contact, telnr 018103880: Mr Prince',
      'buy, house: melbourne lane 132',
      'novel, ch 3: some other text snippet.',
      '"Mr Prince", 01/20/99: need to call about XYZ',
      'project alpha, step 1: upload to github'
    ]

    @db = CFS::Database.new
    @l.each{|l| 
      @db.add (parse_l l)
    }
  end

  def test_db_add
    l4_1 = parse_l "buy, gadgets: www.xyz.com"
    l4_2 = parse_l "buy: www.xyz.com"

    @db.add l4_1
    @db.add l4_2

    assert_equal(@l.length, @db.length)
  end

  def test_filter
    filter_helper "buy"
    filter_helper "buy, house"
    filter_helper "ch"
    filter_helper "ch 5"
  end

  def filter_helper cstr
    puts "Filter: #{cstr}"
    c = parse_cs cstr
    o = @db.filter c
    puts o.inspect
  end

  def parse_l str
    CFS::Parser::parse_l str
  end

  def parse_cs str
    CFS::Parser::parse_cs str
  end

end
