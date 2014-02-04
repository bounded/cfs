require 'test/unit'
require '../cfs.rb'
require '../cfs_fuzzy_tokenizer.rb'
require '../cfs_fuzzy_parser.rb'

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

    @pc1 = CFS::PseudoContainer.new ["abc", "def"]
    @pc2 = CFS::PseudoContainer.new ["abcd", "ghdefh"]
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

  def test_container_implies
    a1 = parse_cs "foo bar"
    a2 = parse_cs "foo"
    a1 = a1[0]
    a2 = a2[0]

    assert(a1.implies? a2)
  end
  
  def test_equal_container
    a1 = parse_cs "foo bar, test"
    a2 = parse_cs "foo bar, test"
    assert(a1 == a2)
  end

  def test_pseudo_container_implies
    assert(@pc2.implies? @pc1)
    assert(not(@pc1.implies? @pc2))
  end

  def test_pseudo_container_contains
    assert(@pc1.contains? (parse_l "before .. abc def .. after"))
  end

  def filter_helper cstr
    # puts "Filter: #{cstr}"
    c = parse_cs cstr
    o = @db.filter c
    # puts o.inspect
  end

  def parse_l str
    CFS::FuzzyParser.literals str
  end

  def parse_cs str
    CFS::FuzzyParser.containers str
  end

end
