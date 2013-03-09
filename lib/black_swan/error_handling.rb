module BlackSwan
  module ErrorHandling
    def self.registered(app)
      app.error do
        e = env["sinatra.error"]
        Slides.log(:exception, class: e.class.name, message: e.message,
          id: request.env["REQUEST_ID"], backtrace: e.backtrace.inspect)
        slim :"errors/500"
      end
    end
  end
end
