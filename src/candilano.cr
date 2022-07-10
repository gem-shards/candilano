require "clim"
require "yaml"
require "colorize"
require "./lib/*"

module Candilano
  VERSION = "0.14.1"
end

Candilano::Cli.start(ARGV) unless ENV["TEST"]? == "true"
