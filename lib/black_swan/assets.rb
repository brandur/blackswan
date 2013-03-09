module BlackSwan
  class Assets < Sinatra::Base
    register ErrorHandling

    def initialize(*args)
      super
      path = "#{BlackSwan::Config.root}/assets"
      @assets = Sprockets::Environment.new do |env|
        Slides.log :assets, path: path

        env.append_path(path + "/images")
        env.append_path(path + "/javascripts")
        env.append_path(path + "/stylesheets")

        if BlackSwan::Config.production?
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      end
    end

    get "/assets/:release/app.css" do
      content_type("text/css")
      respond_with_asset(@assets["app.css"])
    end

    get "/assets/:release/app.js" do
      content_type("application/javascript")
      respond_with_asset(@assets["app.js"])
    end

    %w{ico jpg png}.each do |format|
      get "/assets/:image.#{format}" do |image|
        content_type("image/#{format}")
        respond_with_asset(@assets["#{image}.#{format}"])
      end
    end

    private

    def respond_with_asset(asset)
      halt(404) unless asset
      last_modified(asset.mtime.utc)
      asset
    end
  end
end
