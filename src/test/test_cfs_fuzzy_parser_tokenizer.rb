require 'test/unit' 
require '../cfs_fuzzy_parser.rb'

module TestCFSTokenizerHelper
  def assert_tokenize exp, input
    assert_equal(exp, CFS::FuzzyParser.tokenize_literals(input))
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
    arr = ['the', 'se', :comma, 'a', 're',  :colon, "ma  ny bl  anks"]
    assert_tokenize(arr, str)
  end

  def test_single_quote
    str = '"Test some , : \" stuff" ":more", t"e:\"st" : n"o :,"'
    arr = ['Test some , : " stuff', ':more', :comma, 'te:"st', :colon, 'no :,']
    assert_tokenize(arr, str)
  end

  def test_single_special
    str = "literal:"
    arr = ['literal', :colon]
    assert_tokenize arr, str

    # empty literal without containers
    str = ":"
    arr = [:colon]
    assert_tokenize arr, str

    str = '  '
    arr = ['  ']
    assert_tokenize(arr, str)

    str = ''
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
    arr = ["tag1", :comma, "tag", "2", :comma, "tag3", :colon, "some literal\nstretched across multiple lines\n\nanother literal"]
    assert_tokenize arr, str

    str = <<END
Some simple literal ... 
... continuing here
END
    arr = ["Some simple literal ... \n... continuing here\n"]
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
    arr = ['tag1', :colon, 'Some literal.']
    assert_tokenize(arr, str)

    str = <<END
tag1,tag2: start literal:
Now: I will use another, one    
example that is : 
a lot longer.
   
  
now:   
after the newline
  
END
    arr = ['tag1', :comma, 'tag2', :colon, "start literal:", :break, "Now", :colon, "I will use another, one", :break, "example", "that", "is", :colon, "a lot longer.", :break, 'now', :colon, 'after the newline']

    assert_tokenize(arr, str)
  end

  def test_quotes
    str = <<END
tag1, "Long \\"Tag", oth"e"r tag: here ""\\"are \\\\some
literals\\
  
multiline yeah!
END
    arr = ['tag1', :comma, "Long \"Tag", :comma, 'other', 'tag', :colon, "here \"are \\some\nliterals\n  \nmultiline yeah!"]
    assert_tokenize arr, str
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
tag2, ab:   

tag1, tag2: Literal 1 start. continues...
... 

still the same literal

still ... "4
 
   
... and finished"
END
    arr = ['tag1', :comma, 'ab', :colon, :break, 'tag2', :comma, 'ab', :colon, :break, 'tag1', :comma, 'tag2', :colon, "Literal 1 start. continues...\n... \n\nstill the same literal\n\nstill ... 4\n \n   \n... and finished"]
    assert_tokenize(arr, str)
  end
end

class TestCFSTokenizerContainers < Test::Unit::TestCase

  def test_simple
    str = 'some easy query'
    arr = ['some', 'easy', 'query']
    assert_containers arr, str

    str = "now with newline\n"
    arr = ['now', 'with', 'newline']
    assert_containers arr, str

    str = 'tr"y" "s"o"me" "qu otes"'
    arr = ['try', 'some', 'qu otes']
    assert_containers arr, str

    str = "now\\ with\\ \\\"a \\\\bunch of es\\\"capes"
    arr = ['now with "a', '\\bunch', 'of', 'es"capes']
    assert_containers arr, str

    str = "   and  some\\  \\ ex tra  spaces \\ "
    arr = ['and', 'some ', ' ex', 'tra', 'spaces', ' ']
    assert_containers arr, str
  end

  def assert_containers exp, input
    assert_equal(exp, CFS::FuzzyParser.tokenize_containers(input))
  end

end
