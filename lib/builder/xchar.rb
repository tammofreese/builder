#!/usr/bin/env ruby

# The XChar library is provided courtesy of Sam Ruby (See
# http://intertwingly.net/stories/2005/09/28/xchar.rb)

# --------------------------------------------------------------------

# If the Builder::XChar module is not currently defined, fail on any
# name clashes in standard library classes.

module Builder
  def self.check_for_name_collision(klass, method_name, defined_constant=nil)
    if klass.instance_methods.include?(method_name.to_s)
      fail RuntimeError,
	"Name Collision: Method '#{method_name}' is already defined in #{klass}"
    end
  end
end

if ! defined?(Builder::XChar)
  Builder.check_for_name_collision(String, "to_xs")
  Builder.check_for_name_collision(Fixnum, "xchr")
end

######################################################################
module Builder

  ####################################################################
  # XML Character converter, from Sam Ruby:
  # (see http://intertwingly.net/stories/2005/09/28/xchar.rb). 
  #
  module XChar # :nodoc:

    # See
    # http://intertwingly.net/stories/2004/04/14/i18n.html#CleaningWindows
    # for details.
    CP1252 = {			# :nodoc:
      128 => 8364,		# euro sign
      130 => 8218,		# single low-9 quotation mark
      131 =>  402,		# latin small letter f with hook
      132 => 8222,		# double low-9 quotation mark
      133 => 8230,		# horizontal ellipsis
      134 => 8224,		# dagger
      135 => 8225,		# double dagger
      136 =>  710,		# modifier letter circumflex accent
      137 => 8240,		# per mille sign
      138 =>  352,		# latin capital letter s with caron
      139 => 8249,		# single left-pointing angle quotation mark
      140 =>  338,		# latin capital ligature oe
      142 =>  381,		# latin capital letter z with caron
      145 => 8216,		# left single quotation mark
      146 => 8217,		# right single quotation mark
      147 => 8220,		# left double quotation mark
      148 => 8221,		# right double quotation mark
      149 => 8226,		# bullet
      150 => 8211,		# en dash
      151 => 8212,		# em dash
      152 =>  732,		# small tilde
      153 => 8482,		# trade mark sign
      154 =>  353,		# latin small letter s with caron
      155 => 8250,		# single right-pointing angle quotation mark
      156 =>  339,		# latin small ligature oe
      158 =>  382,		# latin small letter z with caron
      159 =>  376,		# latin capital letter y with diaeresis
    }

    # See http://www.w3.org/TR/REC-xml/#dt-chardata for details.
    PREDEFINED = {
      38 => '&amp;',		# ampersand
      60 => '&lt;',		# left angle bracket
      62 => '&gt;',		# right angle bracket
    }

    # See http://www.w3.org/TR/REC-xml/#charsets for details.
    VALID = [
      0x9, 0xA, 0xD,
      (0x20..0x7F), 
      (0x80..0xD7FF), 
      (0xE000..0xFFFD),
      (0x10000..0x10FFFF)
    ]
  end

end


######################################################################
# Enhance the Fixnum class with a XML escaped character conversion.
#
class Fixnum
  # VALID = Builder::XChar::VALID if ! defined?(VALID)
  # PREDEFINED = Builder::XChar::PREDEFINED if ! defined?(PREDEFINED)
  # 
  # # XML escaped version of chr. When <tt>escape</tt> is set to false
  # # the CP1252 fix is still applied but utf-8 characters are not
  # # converted to character entities.
  # def xchr(escape=true)
  #   case self when *VALID
  #     PREDEFINED[self] or (self<128 ? self.chr : (escape ? "&##{self};" : [self].pack('U*')))
  #   else
  #     '*'
  #   end
  # end
end


######################################################################
# Enhance the String class with a XML escaped character version of
# to_s.
#
class String
  CP1252 = Builder::XChar::CP1252 if ! defined?(CP1252)

  to_character_class_entry = lambda do |entry|
    next "#{[entry].pack('U')}" if entry.is_a? Integer
    next "#{[entry.first].pack('U')}-#{[entry.last].pack('U')}" if entry.is_a? Range
  end
  
  INVALID_UTF8_MATCHER = /[^#{Builder::XChar::VALID.map(&to_character_class_entry).join}]/u
  NON_ASCII_UTF8_MATCHER = /[#{Builder::XChar::VALID[4..-1].map(&to_character_class_entry).join}]/u
  PREDEFINED = Builder::XChar::PREDEFINED.inject({}) { |sum, (key, val)| sum[[key].pack('U')] = val; sum }
  PREDEFINED_UTF_MATCHER = /[#{Builder::XChar::PREDEFINED.keys.map(&to_character_class_entry).join}]/u
  
  # XML escaped version of to_s. When <tt>escape</tt> is set to false
  # the CP1252 fix is still applied but utf-8 characters are not
  # converted to character entities.
  def to_xs(escape=true)
    result = begin
      unpack('U*')
      dup
    rescue
      unpack('C*').map! {|n| CP1252[n] || n }.pack('U*')
    end
    result.gsub!(INVALID_UTF8_MATCHER, '*')
    result.gsub!(PREDEFINED_UTF_MATCHER) { |match| PREDEFINED[match] }
    result.gsub!(NON_ASCII_UTF8_MATCHER) { |match| "&##{match.unpack('U').first};"} if escape
    result
  end  
end