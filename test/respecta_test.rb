require_relative 'test_helper'
require_relative '../lib/respecta'

class RespectaTest < MiniTest::Unit::TestCase

  test 'blank abbreviation scores 0' do
    assert_equal 0, Respecta.new('foo').score('')
    assert_equal 0, Respecta.new('foo').score(nil)
  end

  test 'abbreviation longer than text scores 0' do
    assert_equal 0, Respecta.new('foo').score('foobar')
  end

  test 'invalid abbreviation scores 0' do
    assert_equal 0, Respecta.new('foo').score('z')
  end

  test 'total match scores 1.0' do
    assert_equal 1.0, Respecta.new('foo').score('foo')
  end

  test 'no match scores 0.0' do
    assert_equal 0.0, Respecta.new('foo').score('bar')
    assert_equal 0.0, Respecta.new('foo').score('for')
  end

  test 'partial match scores between 0 and 1' do
    score = Respecta.new('foo').score('fo')
    assert_operator score, :>=, 0
    assert_operator score, :<=, 1
  end

  test 'prefer shorter words to longer ones when same letters matched' do
    s = Respecta.new('foobar').score('bar')
    t = Respecta.new('foobarbaz').score('bar')
    assert_operator s, :>, t
  end

  test 'prioritises final path component (file name)' do
    filename_match_score = Respecta.new('foo/bar').score('bar')
    filepath_match_score = Respecta.new('foo/bar').score('foo')
    assert_operator filename_match_score, :>, filepath_match_score
  end


  #
  # implementation tests (delete once implementation complete)
  #

  test '#match_locations' do
    text = 'app/controllers/search_controller.rb'
    respecta = Respecta.new text

    assert_equal [[]],      respecta.send(:match_locations, text, 'z')
    assert_equal [[35]],    respecta.send(:match_locations, text, 'b')
    assert_equal [[0], [18]], respecta.send(:match_locations, text, 'a')
    assert_equal [[0, 35], [18, 35]], respecta.send(:match_locations, text, 'ab')
  end
end
