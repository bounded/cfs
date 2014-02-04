require 'test/unit' 
require '../cfs_fuzzy_tokenizer.rb'

module TestCFSTokenizerHelper
  def assert_tokenize exp, input
    assert_equal(exp, CFS::FuzzyParser.tokenize(input))
  end
end

class TestCFSTokenizerSingleline < Test::Unit::TestCase
  
  include TestCFSTokenizerHelper

  def test_single_simple
    str = 'a a1, b b1 b2, c: k'
    arr = ["a", "a1", :comma, "b", "b1", "b2", :comma, "c", :colon, "k"]    
    assert_tokenize(arr, str)
  end

  def test_single_escape
    str = 'tag1 tag2, \,comma \:and \ blank, c\:: some test st:,ring'
    arr = ["tag1", "tag2", :comma, ",comma", ":and", " blank", :comma, "c:", :colon, "some test st:,ring"]    
    assert_tokenize(arr, str)
  end

  def test_single_space
    str = ',,,  the  se , a re,, ""  ,,: ma  ny "bl  ank"s'
    arr = ['the', 'se', :comma, 'a', 're',  :colon, "ma  ny \"bl  ank\"s"]
    assert_tokenize(arr, str)
  end

  def test_single_quote
    str = '"Test some , : \" stuff" ":more", t"e:\"st" : n"o :,"'
    arr = ['Test some , : " stuff', ':more', :comma, 'te:"st', :colon, 'n"o :,"']
    assert_tokenize(arr, str)
  end

  def test_single_special
    str = "literal:"
    arr = ['literal:']
    assert_tokenize arr, str

    str = ":"
    arr = [':']
    assert_tokenize arr, str

    str = '  '
    arr = []
    assert_tokenize(arr, str)
  end

end

class TestCFSTokenizerMultiline < Test::Unit::TestCase

  include TestCFSTokenizerHelper

  def test_simple
    str = <<END
tag1, tag 2, tag3: some literal
stretched across multiple lines

another literal
END
    arr = ["tag1", :comma, "tag", "2", :comma, "tag3", :colon, "some literal\nstretched across multiple lines", :break, "another literal"]
    assert_tokenize arr, str

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
  end

  def test_quotes
    str = <<END
tag1, "Long \\"Tag", oth"e"r tag: here ""\\"are \\\\some
literals\\

multiline yeah!
END
    arr = ['tag1', :comma, "Long \"Tag", :comma, 'other', 'tag', :colon, "here \"\"\"are \\some\nliterals\n\nmultiline yeah!"]
    assert_tokenize arr, str
  end

  def test_implicit_escape
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
  end

  def test_space
    str = <<END

 
ab, cd, ef: Some fancy literal.

   
 
h, i"bla": Another, unrelated literal.

  
END
    arr = ['ab', :comma, 'cd', :comma, 'ef', :colon, 'Some fancy literal.', :break, 'h', :comma, 'ibla', :colon, 'Another, unrelated literal.']
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
 
   
... and interrupted"
END
    arr = ['tag1', :comma, 'ab', :colon, :break, 'tag1', :comma, 'tag2', :colon, "Literal 1 start. continues...\n... and ends", :break, "Literal2, start\nLiteral2, end", :break, 'Literal3', :break, "Literal\"4", :break, "... and interrupted\""]
    assert_tokenize(arr, str)
  end

  def test_no_newline
    # test: no newline at the end
    str = <<END
Some literal
  
these aren't \\:tags
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
  end
end
