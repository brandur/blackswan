module BlackSwan
  class Links < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Twitter
    register ErrorHandling

    configure do
      set :views, "#{Config.root}/views"
    end

    get "/href" do
      @title = "Links"

      @links = DB[:events].filter(type: "readability").
        reverse_order(:occurred_at).all

      last_modified(@links.first[:occurred_at])

      @links_by_year = @links.group_by { |t| t[:occurred_at].year }
      @links_by_year_and_month = @links_by_year.merge(@links_by_year) { |y, ts|
        ts.group_by { |t| t[:occurred_at].month }
      }

=begin
      @tweet_count_by_month = {}
      @tweets.reverse.each do |t|
        month = Time.new(t[:occurred_at].year, t[:occurred_at].month)
        @tweet_count_by_month[month] ||= 0
        @tweet_count_by_month[month] += 1
      end
=end

      slim :links
    end
  end
end
