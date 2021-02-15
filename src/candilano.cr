require "clim"
require "yaml"
require "colorize"
require "./lib/*"

module Candilano
  VERSION = "0.12.0"
end

Candilano::Cli.start(ARGV)
