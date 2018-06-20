$stdout.sync = $stderr.sync = true

require "bundler/setup"
Bundler.require

require "./lib/black_swan"

# initialization/configuration
DB = Sequel.connect(BlackSwan::Config.database_url)
Slim::Engine.set_options pretty: !BlackSwan::Config.production?

run BlackSwan::Main
