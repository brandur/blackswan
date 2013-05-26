require "rss"

module BlackSwan::Spiders
  class Blog
    def run
      check_config!
      update
    end

    private

    def check_config!
      raise("missing=BLOG_URL") unless @blog_url = ENV["BLOG_URL"]
    end

    def update
      puts "updating"
      last = nil
      new = 0
      RSS::Parser.parse(open(@blog_url).read, false).items.each do |item|
        next if \
          DB[:events].first(slug: item.link.href, type: "blog") != nil
        last = item
        new += 1

        DB[:events].insert(
          content:     item.title.content,
          occurred_at: Time.parse(item.published.to_s),
          slug:        item.link.href,
          type:        "blog",
          metadata: {
            body: item.content,
          }.hstore)
      end
      puts "processed=#{new} latest=#{last ? last.link.href : nil}"
    end
  end
end
