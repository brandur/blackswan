require "time"

module BlackSwan
  class API < Sinatra::Base
    get "/events", provides: :json do
      @events = DB[:events].order(:occurred_at)
      @events = @events.filter(type: params[:type]) if params[:type]
      @events = @events.limit(params[:limit]) if params[:limit]

      content_type(:json)
      MultiJson.encode(@events.map { |event|
        {
          content:     event[:content],
          metadata:    event[:metadata],
          occurred_at: event[:occurred_at].iso8601,
          slug:        event[:slug],
          type:        event[:type],
        }
      })
    end
  end
end
