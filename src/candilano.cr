require "clim"
require "yaml"
require "colorize"
require "./lib/*"

module Candilano
  VERSION = "0.14.0"
end

Candilano::Cli.start(ARGV)
