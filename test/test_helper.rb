$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "bump/cli"

require "climate_control"
require "minitest/hooks/default"
require "minitest/autorun"
