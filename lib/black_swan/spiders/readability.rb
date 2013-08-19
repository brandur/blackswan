module BlackSwan::Spiders
  class Readability
    def run
      check_config!
      update
      update_content
    end

    private

    def check_config!
      raise("missing=READABILITY_ACCESS_TOKEN") \
        unless ENV["READABILITY_ACCESS_TOKEN"]
      raise("missing=READABILITY_ACCESS_TOKEN_SECRET") \
        unless ENV["READABILITY_ACCESS_TOKEN_SECRET"]
      raise("missing=READABILITY_OAUTH_KEY") \
        unless ENV["READABILITY_OAUTH_KEY"]
      raise("missing=READABILITY_OAUTH_SECRET") \
        unless ENV["READABILITY_OAUTH_SECRET"]
    end

    def oauth_params
      {
        oauth_consumer_key:     ENV["READABILITY_OAUTH_KEY"],
        oauth_nonce:            SecureRandom.hex(20),
        oauth_signature:        "#{ENV["READABILITY_OAUTH_SECRET"]}%26#{ENV["READABILITY_ACCESS_TOKEN_SECRET"]}",
        oauth_signature_method: "PLAINTEXT",
        oauth_timestamp:        Time.now.to_i,
        oauth_token:            ENV["READABILITY_ACCESS_TOKEN"],
      }
    end

    def process_page(options={})
      new = 0
      res = Excon.get(
        "https://www.readability.com/api/rest/v1/bookmarks",
        expects: 200,
        query: oauth_params.merge({
          page:     options[:page],
          per_page: 50,
        }.reject { |k, v| v == nil })
      )
      events = MultiJson.decode(res.body)["bookmarks"]
      events.each do |event|
        next if \
          DB[:events].first(slug: event["article"]["id"], type: "readability") != nil
        new += 1

        DB[:events].insert(
          content:      event["article"]["url"],
          occurred_at:  Time.parse(event["date_added"]),
          slug:         event["article"]["id"],
          type:         "readability",
          metadata: {
            title:      event["article"]["title"],
            word_count: event["article"]["word_count"],
          }.hstore)
      end

      [new, events]
    end

    def update
      puts "updating"
      page = 1
      begin
        loop do
          new, events = process_page(page: page)
          puts "processed=#{new} page=#{page}"
          page += 1
          # if we're not processing new events, it's okay to stop at this page
          break if new < 1
        end
      # we hit the final page, this is expected
      rescue Excon::Errors::NotFound
      end
    end

    def update_content
      puts "updating_content"
      without_content = DB[:events].
        filter(type: "readability").
        filter("NOT exist(metadata, 'content')")
      without_content.each_with_index do |event, i|
        res = Excon.get(
          "https://www.readability.com/api/rest/v1/articles/#{event[:slug]}",
          expects: 200,
          query: oauth_params
        )
        article = MultiJson.decode(res.body)
        DB.run <<-eos
UPDATE events
SET metadata = metadata || hstore('content', #{DB.literal(article["content"])})
WHERE slug = #{DB.literal(event[:slug])}
        eos
        puts "processed=#{i + 1} slug=#{event[:slug]}"
      end
    end
  end
end
