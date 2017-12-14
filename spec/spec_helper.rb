$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "bump/cli"
require "climate_control"

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.expand_path("../", __FILE__)
end

Dir[File.join(SPEC_ROOT, "support/**/*.rb")].each { |f| require f }
