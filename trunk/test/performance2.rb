require 'builder/xmlmarkup'
require 'benchmark'

result = Benchmark.measure do
  xm = Builder::XmlMarkup.new
  xm.instruct!
  xm.links do
    1000000.times do |i|
      xm.link "Item #{i.to_s}"
    end
  end
  x = xm.target!
end
puts result
