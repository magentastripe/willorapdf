#!/usr/bin/env ruby

require 'optparse'
require 'mini_magick'

image = nil
left_out = nil
right_out = nil

# Parse and verify command-line arguments.
parser = OptionParser.new do |opts|
  opts.on("--input PATH") { |path| image = File.expand_path(path) }
  opts.on("--left-out PATH") { |path| left_out = File.expand_path(path) }
  opts.on("--right-out PATH") { |path| right_out = File.expand_path(path) }
end
parser.parse!(ARGV)

if not image
  $stderr.puts("FATAL: expected an image.")
  exit 1
end

if not [left_out, right_out].all?
  $stderr.puts("FATAL: expected L and R output images.")
  exit 1
end

if not File.file?(image)
  $stderr.puts("FATAL: no such file: #{image}")
  exit 1
end

# Split the image into two halves.
image_f = MiniMagick::Image.open(image)
w, h = image_f.dimensions
new_w = w/2
$stderr.puts("Input image #{File.basename(image)} has dimensions #{w}x#{h}")
$stderr.puts("Will create two images of size #{new_w}x#{h}")

lefthand_crop = image_f.crop("#{new_w}x#{h}+0+0")
lefthand_crop.write(left_out)

# Need to open the original image twice in order to get back to the
# "starting point."
image_f = MiniMagick::Image.open(image)
righthand_crop = image_f.crop("#{new_w}x#{h}+#{new_w}+0")
righthand_crop.write(right_out)
