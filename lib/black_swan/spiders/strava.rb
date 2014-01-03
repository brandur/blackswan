require "uri"

module BlackSwan::Spiders
  class Strava
    def run
      check_config!
      latest = DB[:events].filter(type: "strava").max("occurred_at".lit)
      update(latest) if latest
      backfill if !latest
    end

    private

    def backfill
      puts "backfilling"
      earliest = nil
      begin
        new, events = process_page(before: earliest)
        puts "processed=#{new} earliest=#{earliest}"
        earliest = events.count > 0 ?
          events.min_by { |e| e["occurred_at"] }["occurred_at"] :
          nil
      end while new > 0
    end

    def check_config!
      raise("missing=STRAVA_ACCESS_TOKEN") unless ENV["STRAVA_ACCESS_TOKEN"]
    end

    def process_page(options={})
      new = 0
      res = Excon.get(
        "https://www.strava.com/api/v3/athlete/activities",
        expects: 200,
        body: URI.encode_www_form({
          access_token:     ENV["STRAVA_ACCESS_TOKEN"],
          after:            options[:after] ? options[:after].to_i : nil,
          before:           options[:before] ? options[:before].to_i : nil,
          per_page:         200,
        }.reject { |k, v| v == nil }),
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
        })
      events = MultiJson.decode(res.body)
      events.each do |event|
        next if \
          DB[:events].first(slug: event["id"].to_s, type: "strava") != nil
        new += 1

        DB[:events].insert(
          content:     event["name"],
          occurred_at: Time.parse(event["start_date"]),
          slug:        event["id"].to_s,
          type:        "strava",
          metadata: {
            calories:       event["calories"],
            distance:       event["distance"],
            elapsed_time:   event["elapsed_time"],
            location_city:  event["location_city"],
            location_state: event["location_state"],
            moving_time:    event["moving_time"],
            type:           event["type"],
          }.hstore)
      end

      [new, events]
    end

    def update(latest)
      puts "updating"
      begin
        new, events = process_page(after: latest)
        puts "processed=#{new} latest=#{latest}"
        latest = events.count > 0 ?
          events.max_by { |e| e["occurred_at"] }["occurred_at"] :
          nil
      end while new > 0
    end
  end
end
