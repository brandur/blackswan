module BlackSwan::Spiders
  class Twitter
    def run
      check_config!
      update
      backfill
    end

    private

    def backfill
      puts "backfilling"
      earliest = DB[:events].filter(type: "twitter").min(Sequel.lit("slug::bigint"))
      begin
        new, events = process_page(max_id: earliest)
        puts "processed=#{new} earliest=#{earliest}"
        earliest = events.count > 0 ? events.min_by { |e| e["id"] }["id"] : nil
      end while new > 0
    end

    def check_config!
      raise("missing=TWITTER_ACCESS_TOKEN") unless ENV["TWITTER_ACCESS_TOKEN"]
      raise("missing=TWITTER_HANDLE") unless ENV["TWITTER_HANDLE"]
    end

    def expand_urls(event)
      content = event["text"]
      # axe Twitter's crappy shortlinks
      if event["entities"]
        event["entities"]["urls"].each do |url|
          if url["expanded_url"]
            content.sub!(url["url"], url["expanded_url"])
          end
        end
      end
      content
    end

    def process_page(options={})
      new = 0
      res = Excon.get(
        "https://api.twitter.com/1.1/statuses/user_timeline.json",
        expects: 200,
        headers: {
          "Authorization" => "Bearer #{ENV["TWITTER_ACCESS_TOKEN"]}"
        },
        query: {
          count:            200,
          include_entities: "true",
          max_id:           options[:max_id],
          screen_name:      ENV["TWITTER_HANDLE"],
          since_id:         options[:since_id],
          trim_user:        "true",
        }.reject { |k, v| v == nil })
      events = MultiJson.decode(res.body)
      events.each do |event|
        next if \
          DB[:events].first(slug: event["id"].to_s, type: "twitter") != nil
        new += 1

        DB[:events].insert(
          content:     expand_urls(event),
          occurred_at: event["created_at"],
          slug:        event["id"].to_s,
          type:        "twitter",
          metadata: Sequel.hstore({
            reply:     (event["text"] =~ /\A\s*@/) != nil,
          }))
      end

      [new, events]
    end

    def update
      puts "updating"
      latest = DB[:events].filter(type: "twitter").max(Sequel.lit("slug::bigint"))
      begin
        new, events = process_page(since_id: latest)
        puts "processed=#{new} latest=#{latest}"
        latest = events.count > 0 ? events.max_by { |e| e["id"] }["id"] : nil
      end while new > 0
    end
  end
end
