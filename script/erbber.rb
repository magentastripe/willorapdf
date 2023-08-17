#!/usr/bin/env ruby
#
# WilloraPDF template renderer
# Charlotte Koch <charlotte@magentastripe.com>
#

require 'erb'
require 'optparse'

input = nil
defines = {}

# Parse command line options.
parser = OptionParser.new do |opts|
  opts.on("-i", "--input FILE") { |path| input = File.expand_path(path) }
  opts.on("-D", "--define KEY=VALUE") { |arg| d = arg.split("="); defines[d[0]] = d[1]; }
end
parser.parse!(ARGV)

# Validate the command line options.
if not File.file?(input)
  $stderr.puts("FATAL: no such file: #{input}")
  exit 1
end

defines.each do |k, v|
  if v && !k
    $stderr.puts("pair is missing a key: #{[k,v].inspect}")
    exit 1
  end

  if k && !v
    $stderr.puts("pair is missing a value: #{[k,v].inspect}")
    exit 1
  end
end

# Set up the variable binding sandbox which will be given to the template.
class OurEnvironment
  attr_reader :var

  def initialize(data)
    @var = data
  end

  def get_binding
    return binding
  end
end

our_env = OurEnvironment.new(defines)

# Render the template to standard output.
result = ERB.new(File.read(input)).result(our_env.get_binding)
$stdout.puts(result)
