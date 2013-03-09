module BlackSwan
  Main = Rack::Builder.new do
    use Rack::Instruments
    use Rack::SSL if Config.force_ssl?
    run Sinatra::Router.new {
      mount Assets
      mount Twitter
      run   Default # index + error handlers
    }
  end
end
