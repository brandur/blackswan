require "base64"

module BlackSwan::Spiders
  class TripIt
    def run
      check_config!
      update
    end

    private

    def check_config!
      raise("missing=TRIP_IT_EMAIL") unless @trip_it_email = ENV["TRIP_IT_EMAIL"]
      raise("missing=TRIP_IT_PASSWORD") unless @trip_it_password = ENV["TRIP_IT_PASSWORD"]
    end

    def update
      puts "updating"
      new = 0
      res = Excon.get(
        "https://api.tripit.com/v1/list/trip/past/true",
        expects: 200,
        headers: {
          "Authorization" => "Basic #{Base64.urlsafe_encode64("#{@trip_it_email}:#{@trip_it_password}")}"
        },
        query: {
          format: "json",
          page_size: "1000",
        })
      data = MultiJson.decode(res.body)
      events = data["Trip"].sort_by { |e| e["start_date"] }
      events.each do |event|
        next if \
          DB[:events].first(slug: event["id"].to_s, type: "tripit") != nil
        new += 1

        DB[:events].insert(
          content:     event["display_name"],
          occurred_at: Time.parse(event["start_date"]).getutc,
          slug:        event["id"].to_s,
          type:        "tripit",
          metadata: Sequel.hstore({
            end_date:   event["end_date"],
            location:   event["primary_location"],
            private:    event["is_private"],
            start_date: event["start_date"],
          }))
      end
      puts "processed=#{new} latest=#{events.last ? events.last["display_name"] : nil}"
    end
  end
end
