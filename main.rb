require "./my_parser"

require "optparse"

h = {}
opt = OptionParser.new
opt.on("--debug")
rest = opt.parse(ARGV, into: h)

p MyParser.new(rest.first, debug: h.fetch(:debug, false)).parse
