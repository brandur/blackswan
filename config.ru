$stdout.sync = $stderr.sync = true

require "bundler/setup"
Bundler.require

require "./lib/black_swan"

# initialization/configuration
Slim::Engine.set_default_options pretty: !BlackSwan::Config.production?

run BlackSwan::Main
