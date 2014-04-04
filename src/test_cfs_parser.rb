require 'test/unit'
require 'pry'
require_relative 'cfs_parser.rb'

class TestCFSParser < Test::Unit::TestCase
  def test_simple
    r = p_l("a")
    e = c("a")
    assert_equal r, e

    r = p_l "a:b" 
    e = c('a', [c('b')] )
    assert_equal r, e

    r = p_l "(a,b)" 
    e = c(nil, [c('a'), c('b')] )
    assert_equal r, e

    r = p_l "a:b:c:d" 
    e = c('a', [c('b', [c('c', [c('d')] )] )] )
    assert_equal r, e

    r = p_l "(a,b,c,d)" 
    e = c(nil, [c('a'), c('d'), c('c'), c('b')] )
    assert_equal r, e
  end

  def test_nested
    r = p_l "a:b:(c:d,e:(f:g,h:i))"
    e = c('a', [
          c('b', [
            c('c', [c('d')] ),
            c('e', [
              c('h', [c('i')]),
              c('f', [c('g')])
    ] )
    ] )
    ] )
    assert_equal r, e
  end

  def test_parentheses
    r = p_l "(((a)))"
    e = c('a')
    assert_equal r, e

    r = p_l "(a:((b)))"
    e = c('a',[c('b')])
    assert_equal r, e

    # note that ((a)):b is not allowed
    # since S -> V | V:S
    # and V cannot contain any parentheses
    
    r = p_l "(a:b:((c:((d,((e)))))))"
    e = c('a', [
          c('b', [
            c('c', [
              c('d'),
              c('e')
    ] )
    ] )
    ] )
    assert_equal r, e
  end

  def test_realistic_1
    r = p_l "( project:(cfs, version:1.01), todo:bug:(prio:2, desc:Crash, platform:Windows 7 64bit, processor:Intel))"
    e = c(nil, [
         c('project', [
           c('cfs'),
           c('version', [c('1.01')])
         ] ),
         c('todo', [
           c('bug', [
             c('prio', [c('2')]),
             c('desc', [c('Crash')]),
             c('platform', [c('Windows 7 64bit')]),
             c('processor', [c('Intel')])
           ] )
         ] ) 
    ] )

    assert_equal r, e
  end

  def test_preprocessor
    db_s =
<<HERE
    a, b

    a: 
    b
    c

    c:
HERE
    r = CFS::Parser.parse db_s    
    e = c(nil, [
          c(nil, [ c('a'), c('b') ]),
          c('a', [ c('b') ]),
          c('a', [ c('c') ])
    ])

    assert_equal r, e
  end

  def p_l str
    CFS::Parser.parse_line str
  end

  def c a=nil, b=Set.new
    if b.is_a? Array
      tmp = Set.new b
      b = tmp
    end
    CFS::Container.new a, b
  end

end
