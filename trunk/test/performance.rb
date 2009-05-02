require 'builder/xmlmarkup'
require 'rubygems'
require 'ruby-prof'

result = RubyProf.profile do
  xm = Builder::XmlMarkup.new
  xm.instruct!
  xm.links do
    100000.times do |i|
      xm.link i.to_s
    end
  end
  x = xm.target!
end
RubyProf::FlatPrinter.new(result).print(STDOUT, 0)
