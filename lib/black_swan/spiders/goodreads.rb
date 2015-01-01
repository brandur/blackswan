require "xml"

module BlackSwan::Spiders
  class Goodreads
    def run
      check_config!
      update
    end

    private

    def check_config!
      raise("missing=GOODREADS_ID")  unless ENV["GOODREADS_ID"]
      raise("missing=GOODREADS_KEY") unless ENV["GOODREADS_KEY"]
    end

    def process_page(options={})
      new = 0
      res = Excon.get(
        "http://www.goodreads.com/review/list/#{ENV["GOODREADS_ID"]}.xml",
        expects: 200,
        query: {
          key:      ENV["GOODREADS_KEY"],
          page:     options[:page],
          per_page: 20,
          shelf:    "read",
          sort:     "date_read",
          v:        "2",
        })
      parser = XML::Parser.string(res.body)
      doc = parser.parse
      doc.find("//reviews/review").each do |x|
        id = x.find('book/id').first.content
        next if DB[:events].first(slug: id, type: "goodreads") != nil
        new += 1

        DB[:events].insert(
          occurred_at:
            (Time.parse(x.find('read_at').first.content) rescue Time.at(0)),
          slug:        id,
          type:        "goodreads",
          metadata: Sequel.hstore({
            author:    x.find('book/authors/author').map { |a|
              a.find('name').first.content.strip
            }.join(", "),
            isbn:      x.find('book/isbn13').first.content,
            num_pages: x.find('book/num_pages').first.content,
            rating:    x.find('rating').first.content,
            title:     x.find('book/title').first.content.strip,
          }))
      end
      new
    end

    def update
      page = 1
      puts "updating"
      begin
        new = process_page(page: page)
        puts "processed=#{new} page=#{page}"
        page += 1
      end while new > 0
    end
  end
end
