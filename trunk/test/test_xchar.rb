#!/usr/bin/env ruby

require 'test/unit'
require 'builder/xchar'

class TestXmlEscaping < Test::Unit::TestCase
  def test_ascii
    assert_equal 'abc', 'abc'.to_xs
  end

  def test_predefined
    assert_equal '&amp;', '&'.to_xs              # ampersand
    assert_equal '&lt;',  '<'.to_xs              # left angle bracket
    assert_equal '&gt;',  '>'.to_xs              # right angle bracket
  end

  def test_invalid
    assert_equal '*', "\x00".to_xs               # null
    assert_equal '*', "\x0C".to_xs               # form feed
    assert_equal '*', "\xEF\xBF\xBF".to_xs       # U+FFFF
  end

  def test_iso_8859_1
    assert_equal '&#231;', "\xE7".to_xs          # small c cedilla
    assert_equal '&#169;', "\xA9".to_xs          # copyright symbol
  end

  def test_win_1252
    assert_equal '&#8217;', "\x92".to_xs         # smart quote
    assert_equal '&#8364;', "\x80".to_xs         # euro
  end
  
  def test_win_1252_escaping
    assert_equal '&#8364;', "\x80".to_xs(true)   # euro with escaping
    assert_equal '€', "\x80".to_xs(false)  # euro without escaping
  end

  def test_do_not_fix_utf8_as_win_1252
    assert_equal '&#8224;', "\x86".to_xs         # CP1252 dagger
    assert_equal '&#134;',  "\xC2\x86".to_xs     # UTF-8 reverse line feed
  end

  def test_utf8
    assert_equal '&#8217;', "\xE2\x80\x99".to_xs # right single quote
    assert_equal '&#169;',  "\xC2\xA9".to_xs     # copy
  end
 
  def test_utf8_verbatim
    assert_equal "\xE2\x80\x99", "\xE2\x80\x99".to_xs(false)  # right single quote
    assert_equal "\xC2\xA9",  "\xC2\xA9".to_xs(false)         # copy
    assert_equal "\xC2\xA9&amp;\xC2\xA9",
      "\xC2\xA9&\xC2\xA9".to_xs(false)                        # copy with ampersand
  end
end
