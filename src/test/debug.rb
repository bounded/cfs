require 'pry'
require '../cfs_fuzzy_parser.rb'

def test_1
  # test: one tag and one literal in new line with break
  str = <<END
tag1:

Some literal.
END
  arr = ['tag1', :colon, :break, 'Some literal.']
  assert_tokenize(arr, str)
  end

  def assert_tokenize exp, input
    assert_equal(exp, CFS::FuzzyParser.tokenize(input))
  end
