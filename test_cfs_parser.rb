require 'test/unit' 
require './cfs.rb'
require './cfs_parser.rb'

class TestCFSParser < Test::Unit::TestCase
  
  def test_tokenize
    str = 'a a1, b b1 b2, c: "k"'
    arr = ["a", "a1", :comma, "b", "b1", "b2", :comma, "c", :colon, "k"]    
    assert_equal(arr, CFS::Tokenizer::tokenize(str))
  end
    
  def test_tokenize_escape
    str = 'tag1 tag2, \,comma \:and \ blank, c\:: some test st:ring'
    arr = ["tag1", "tag2", :comma, ",comma", ":and", " blank", :comma, "c:", :colon, "some test st:ring"]    
    assert_equal(arr, CFS::Tokenizer::tokenize(str))
  end

  def test_tokenize_space
    str = '  the  se , a re, ""  : ma  ny "bl  ank"s'
    arr = ['the', 'se', :comma, 'a', 're', :comma,  :colon, "ma  ny bl  anks"]
    assert_equal(arr, CFS::Tokenizer::tokenize(str))
  end

  def test_tokenize_quote
    str = '"Test some , : \" stuff" ":more", t"e:\"st" : n"o :,"'
    arr = ['Test some , : " stuff', ':more', :comma, 'te:"st', :colon, 'no :,']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))
  end

  def test_tokenize_carr
    str = 'todo'
    arr = ['todo']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))

    str = 't1, t2'
    arr = ['t1', :comma, 't2']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))

    str = 'att val'
    arr = ['att', 'val']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))

    str = 'a "klm:"'
    arr = ['a', 'klm:']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))

    str = 'a b c, d "Hello Guys"'
    arr = ['a', 'b', 'c', :comma, 'd', 'Hello Guys']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))

    str = 'a, d "Hell"o'
    arr = ['a', :comma, 'd', 'Hello']
    assert_equal(arr, CFS::Tokenizer::tokenize(str))
  end

  def test_parser_1
    str = "s a, b, c: d"
    l = CFS::Literal.new "d"
    l.container = [
      CFS::Container.new(["s", "a"]),
      CFS::Container.new(["b"]),
      CFS::Container.new(["c"])
    ]
    out = CFS::Parser::parse_l(str) 

    assert(l.eql? out)
  end

end
