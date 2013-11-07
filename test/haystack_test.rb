require_relative 'test_helper'
require_relative '../lib/haystack'

class HaystackTest < MiniTest::Unit::TestCase

  test 'score' do
    haystack = Haystack.new('foo')
    assert_equal 1, haystack.score([0,1,2])
    assert_operator haystack.score([0, 1, 2]), :>, haystack.score([0, 1])
    assert_operator haystack.score([0, 1]),    :>, haystack.score([0])
  end

  #
  # implementation tests (delete once implementation complete)
  #

  test 'sanity check' do
    assert_equal 6, Haystack.new('foo').send(:maximum_score)
    assert_equal 6, Haystack.new('foo').send(:absolute_score, [0,1,2])
  end

  test 'partial match' do
    assert_equal 3, Haystack.new('foo').send(:absolute_score, [0,2])
    assert_equal 4, Haystack.new('foo').send(:absolute_score, [0,1])
    assert_equal 3, Haystack.new('foo').send(:absolute_score, [1,2])
  end

  test 'prefers start of words' do
    assert_equal 1, Haystack.new('foo').send(:absolute_score, [1])
    assert_equal 2, Haystack.new('foo').send(:absolute_score, [0])
    assert_equal 2, Haystack.new('foo/bar').send(:absolute_score, [4])
    assert_equal 2, Haystack.new('foo/barQux').send(:absolute_score, [7])
    assert_equal 2, Haystack.new('foo/bar_qux').send(:absolute_score, [8])
  end

  test 'prefers contiguous letters' do
    assert_equal 2, Haystack.new('foobar').send(:absolute_score, [1, 3])
    assert_equal 3, Haystack.new('foobar').send(:absolute_score, [2, 3])
  end

  test '#individual_letter_scores' do
    assert_equal [2],             Haystack.new('f').send(:individual_letter_scores)
    assert_equal [2, 1],          Haystack.new('fo').send(:individual_letter_scores)
    assert_equal [2, 1, 1],       Haystack.new('fo/').send(:individual_letter_scores)
    assert_equal [2, 1, 1, 2],    Haystack.new('fo/b').send(:individual_letter_scores)
    assert_equal [2, 1, 1, 2, 1], Haystack.new('fo/ba').send(:individual_letter_scores)
    assert_equal [2, 1, 2, 1],    Haystack.new('foBa').send(:individual_letter_scores)
    assert_equal [2, 1, 1, 2],    Haystack.new('fo_b').send(:individual_letter_scores)
  end
  
  test '#contiguous_letter_scores' do
    assert_equal 0, Haystack.new('whatever').send(:contiguous_letters_score, [0])
    assert_equal 1, Haystack.new('whatever').send(:contiguous_letters_score, [0, 1])
    assert_equal 0, Haystack.new('whatever').send(:contiguous_letters_score, [0, 2])
    assert_equal 3, Haystack.new('whatever').send(:contiguous_letters_score, [0, 1, 3, 5, 8, 9, 10])
  end
  
end
