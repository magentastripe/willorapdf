#
# unicodify.rb
# Charlotte Koch <charlotte@magentastripe.com>
#
# This file is part of Willora.
#
# This script translates HTML entities on the standard input to numerical
# Unicode codepoints on the standard output. This script uses a whole bunch
# of memory in order to keep it fast.
#

require 'json'

entities = JSON.load(File.read("./private/entities.min.json"))

out = $stdin.read

entities.each do |entity, value|
  result = value["codepoints"].map { |n| sprintf('&#%d;', n) }.join("")
  out.gsub!(entity, result)
end

$stdout.write(out)
