require 'test/unit' 
require '../cfs_fuzzy_parser.rb'

class TestCFSTokenizer < Test::Unit::TestCase
  
  def test_tokenize
    str = 'a a1, b b1 b2, c: "k"'
    arr = ["a", "a1", :comma, "b", "b1", "b2", :comma, "c", :colon, "k"]    
    assert_tokenize(arr, str)
  end
    
  def test_tokenize_escape
    str = 'tag1 tag2, \,comma \:and \ blank, c\:: some test st:,ring'
    arr = ["tag1", "tag2", :comma, ",comma", ":and", " blank", :comma, "c:", :colon, "some test st:,ring"]    
    assert_tokenize(arr, str)
  end

  def test_tokenize_space
    str = '  the  se , a re, ""  : ma  ny "bl  ank"s'
    arr = ['the', 'se', :comma, 'a', 're', :comma,  :colon, "ma  ny bl  anks"]
    assert_tokenize(arr, str)
  end

  def test_tokenize_quote
    str = '"Test some , : \" stuff" ":more", t"e:\"st" : n"o :,"'
    arr = ['Test some , : " stuff', ':more', :comma, 'te:"st', :colon, 'no :,']
    assert_tokenize(arr, str)

  end

  def test_tokenize_special_cases
    str = ': literal'
    arr = [:colon, 'literal']
    assert_tokenize(arr, str)

    str = ':'
    arr = [:colon]
    assert_tokenize(arr, str)

    str = '  '
    arr = []
    assert_tokenize(arr, str)

    str = 'a, closing "quote is \\\\ not needed'
    arr = ['a', :comma, 'closing', 'quote is \\ not needed']
    assert_tokenize(arr, str)
  end

  def test_tokenize_containers
    str = 'todo'
    arr = ['todo']
    assert_tokenize(arr, str)

    str = 't1, t2'
    arr = ['t1', :comma, 't2']
    assert_tokenize(arr, str)

    str = 'att val'
    arr = ['att', 'val']
    assert_tokenize(arr, str)

    str = 'a "klm:"'
    arr = ['a', 'klm:']
    assert_tokenize(arr, str)

    str = 'a b c, d "Hello Guys"'
    arr = ['a', 'b', 'c', :comma, 'd', 'Hello Guys']
    assert_tokenize(arr, str)

    str = 'a, d "Hell"o"f"'
    arr = ['a', :comma, 'd', 'Hellof']
    assert_tokenize(arr, str)
  end

  def test_tokenize_multiline_space
    # test: one literal with unnecessary space
    str = <<END
Some literal
  
 
END
    arr = ['Some literal']
    assert_tokenize(arr, str)
     
    # test: no newline at the end
    str = <<END
Some literal
  
these aren't \:tags
END
    # remove newline
    str = str[0..str.length-2]
    arr = ['Some literal',:break, 'these aren\'t \\:tags']
    assert_tokenize(arr, str)

    # test: no newline at the end, with tags
    str = <<END
Some literal
  
these, are: tags
END
    # remove newline
    str = str[0..str.length-2]
    arr = ['Some literal',:break, 'these', :comma, 'are', :colon, 'tags']
    assert_tokenize(arr, str)
    # test :break
    str = <<END

 
ab, cd, ef: Some fancy literal.

   
 
h, i"bla": Another, unrelated literal.

  
END
    arr = ['ab', :comma, 'cd', :comma, 'ef', :colon, 'Some fancy literal.', :break, 'h', :comma, 'ibla', :colon, 'Another, unrelated literal.']
    assert_tokenize(arr, str)

  end


  def test_tokenize_multiline
    # test: simple literals
    str = <<END
Some simple literal ... 
... continuing here
END
    arr = ["Some simple literal ... \n... continuing here"]
    assert_tokenize(arr, str)

    # test: one tag and one literal in new line
    str = <<END
tag1:
Some literal.
END
    arr = ['tag1', :colon, 'Some literal.']
    assert_tokenize(arr, str)
    
    # test: one tag and one literal in new line with break
    str = <<END
tag1:

Some literal.
END
    arr = ['tag1', :colon, :break, 'Some literal.']
    assert_tokenize(arr, str)
    
    # test: escaping
    str = <<END
tag1,tag2: start literal:
Now: I will use many, many 
characters that usually: need
to be escaped.

now:
after the newline, they should no longer be escaped
END
    arr = ['tag1', :comma, 'tag2', :colon, "start literal:\nNow: I will use many, many \ncharacters that usually: need\nto be escaped.", :break, 'now', :colon, 'after the newline, they should no longer be escaped']

    assert_tokenize(arr, str)

    # test: literals containing newlines
    str = <<END
tag1, ab:

tag1, tag2: Literal 1 start. continues...
... and ends

Literal2, start
Literal2, end

Literal3

Literal"4
  
and still going"
END
    arr = ['tag1', :comma, 'ab', :colon, :break, 'tag1', :comma, 'tag2', :colon, "Literal 1 start. continues...\n... and ends", :break, "Literal2, start\nLiteral2, end", :break, 'Literal3', :break, "Literal4\n  \nand still going"]
    assert_tokenize(arr, str)

    str = <<END
tag1, tag2

tag3: literal
END
    arr = ['tag1, tag2', :break, 'tag3', :colon, 'literal']
    assert_tokenize(arr, str)

    # test: containers at the end
    str = <<END
literal

c1, c2, c3:
END
    arr = ['literal', :break, 'c1, c2, c3:']
    assert_tokenize(arr, str)

  end

  def assert_tokenize exp, input
    assert_equal(exp, CFS::FuzzyParser.tokenize(input))
  end

end
