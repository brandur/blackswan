module BlackSwan
  Main = Rack::Builder.new do
    use Rack::Instruments
    use Rack::SSL if Config.force_ssl?
    run Sinatra::Router.new {
      mount API
      mount Assets
      mount Goodreads  # /books
      mount Twitter    # /twitter
      run   Default    # / + error handlers
    }
  end
end
