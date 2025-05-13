#
# The entities.json file from WHATWG contains a bunch of duplicates. In
# particular, I don't care about entities that aren't terminated with a
# semicolon -- i.e., Willora users MUST terminate HTML codes with a
# semicolon.
#
# This script massages entites.json into a smaller and (in my opinion)
# equivalent file.
#
# References:
#
# - WHATWG's table of named chars
#     https://html.spec.whatwg.org/multipage/named-characters.html
#
# - URL for the entities.json itself
#     https://html.spec.whatwg.org/entities.json
#

require 'json'

def semicoloned?(str)
  return str[-1] == ";"
end

arg = ARGV.shift

entities = JSON.load(File.read(arg))

new_entities = entities.
  select { |k, v| semicoloned?(k) }.
  map { |k, v| v.delete("characters"); [k, v] }

puts JSON.generate(Hash[new_entities])
