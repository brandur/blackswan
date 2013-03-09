module BlackSwan
  module Config
    extend self

    def database_url
      @database_url ||= ENV["DATABASE_URL"] || raise("missing=DATABASE_URL")
    end

    def force_ssl?
      @force_ssl ||= %w{1 true yes}.include?(ENV["FORCE_SSL"])
    end

    def production?
      ENV["RACK_ENV"] == "production"
    end

    # just a dumb token that allows us to force reloading of JS and style
    # assets
    def release
      @release ||= ENV["RELEASE"] || "1"
    end

    def root
      @root ||= File.expand_path("../../../", __FILE__)
    end

    def twitter_handle
      @twitter_handle ||= ENV["TWITTER_HANDLE"] ||
        raise("missing=TWITTER_HANDLE")
    end
  end
end
