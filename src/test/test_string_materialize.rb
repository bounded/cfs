require 'test/unit'
require '../cfs_fuzzy_parser.rb'

class TestString < Test::Unit::TestCase

  def test_1
    r = /[\s:,]/
    str = 'test something " :,\\"\' random text" hello'
    str.materialize_quotes! r
    assert_equal 'test something \\ \\:\\,"\'\\ random\\ text hello', str
  end

end
