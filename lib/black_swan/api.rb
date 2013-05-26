require "time"

module BlackSwan
  class API < Sinatra::Base
    get "/events", provides: :json do
      @events = DB[:events].order(:occurred_at)
      @events = @events.filter(type: params[:type]) if params[:type]

      content_type(:json)
      MultiJson.encode(@events.map { |event|
        {
          content:     event[:content],
          occurred_at: event[:occurred_at].iso8601,
          slug:        event[:slug],
          type:        event[:type],
        }
      })
    end
  end
end
