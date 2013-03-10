module BlackSwan::Spiders
  class Twitter
    def run
      update
      backfill
    end

    private

    def backfill
      puts "backfilling"
      earliest = DB[:events].min("slug::bigint".lit)
      begin
        new, events = process_page(max_id: earliest)
        puts "processed=#{new} earliest=#{earliest}"
        earliest = events.count > 0 ? events.min_by { |e| e["id"] }["id"] : nil
      end while new > 0
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
        "https://api.twitter.com/1/statuses/user_timeline.json",
        expects: 200,
        query: {
          count:            200,
          include_entities: "true",
          max_id:           options[:max_id],
          screen_name:      BlackSwan::Config.twitter_handle,
          since_id:         options[:since_id],
          trim_user:        "true",
        }.reject { |k, v| v == nil })
      events = MultiJson.decode(res.body)
      events.each do |event|
        next if DB[:events].first(slug: event["id"].to_s) != nil
        new += 1

        DB[:events].insert(
          content:     expand_urls(event),
          occurred_at: event["created_at"],
          slug:        event["id"].to_s,
          metadata: {
            reply:     (event["text"] =~ /^\s*@/) != nil,
          }.hstore)
      end

      [new, events]
    end

    def update
      puts "updating"
      latest = DB[:events].max("slug::bigint".lit)
      begin
        new, events = process_page(since_id: latest)
        puts "processed=#{new} latest=#{latest}"
        latest = events.count > 0 ? events.max_by { |e| e["id"] }["id"] : nil
      end while new > 0
    end
  end
end
