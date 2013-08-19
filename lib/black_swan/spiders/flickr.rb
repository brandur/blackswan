module BlackSwan::Spiders
  class Flickr
    def run
      check_config!
      configure
      update
    end

    private

    def check_config!
      raise("missing=FLICKR_API_KEY") unless ENV["FLICKR_API_KEY"]
      raise("missing=FLICKR_EMAIL") unless ENV["FLICKR_EMAIL"]
      raise("missing=FLICKR_SHARED_SECRET") unless ENV["FLICKR_SHARED_SECRET"]
    end

    def configure
      FlickRaw.api_key       = ENV["FLICKR_API_KEY"]
      FlickRaw.shared_secret = ENV["FLICKR_SHARED_SECRET"]

      @user_id = flickr.people.findByEmail(
        find_email: ENV["FLICKR_EMAIL"],
      )["id"]
    end

    def process_page(options={})
      new = 0
      events = flickr.people.getPublicPhotos(
        extras:   "description,date_upload,tags,url_m",
        page:     options[:page],
        per_page: 500,
        user_id:  @user_id,
      )
      events.each do |event|
        # tons of photos, so for now only pull over if tagged with "lifestream"
        next unless event["tags"].split.include?("lifestream")

        next if \
          DB[:events].first(slug: event["id"], type: "flickr") != nil
        new += 1

        DB[:events].insert(
          occurred_at:     Time.at(event["dateupload"].to_i),
          slug:            event["id"],
          type:            "flickr",
          metadata: {
            description:   event["description"],
            medium_image:  event["url_m"],
            medium_height: event["height_m"],
            medium_width:  event["width_m"],
            title:         event["title"],
          }.hstore)
      end

      [new, events]
    end

    def update
      puts "updating"
      page = 1
      loop do
        new, events = process_page(page: page)
        puts "processed=#{new} page=#{page}"
        page += 1
        # after we've paged too far, events will no longer be returned
        break if events.size < 1
      end
    end
  end
end
