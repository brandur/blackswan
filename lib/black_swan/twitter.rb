module BlackSwan
  class Twitter < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Twitter
    register ErrorHandling

    configure do
      set :views, "#{Config.root}/views"
    end

    get "/twitter" do
      @title = "Twitter"

      @tweets = DB[:events].filter(type: "twitter").
        reverse_order(:occurred_at)

      last_modified(@tweets.first[:occurred_at])

      @tweet_count              = @tweets.
        filter(Sequel.lit("metadata -> 'reply' = 'false'")).count
      @tweet_count_with_replies = @tweets.count

      @tweets = @tweets.filter(Sequel.lit("metadata -> 'reply' = 'false'")) \
        if params[:with_replies] != "true"
      @tweets = @tweets.all

      @tweets_by_year = @tweets.group_by { |t| t[:occurred_at].year }
      @tweets_by_year_and_month = @tweets_by_year.merge(@tweets_by_year) { |y, ts|
        ts.group_by { |t| t[:occurred_at].month }
      }

      @tweet_count_by_month = {}
      @tweets.reverse.each do |t|
        month = Time.new(t[:occurred_at].year, t[:occurred_at].month)
        @tweet_count_by_month[month] ||= 0
        @tweet_count_by_month[month] += 1
      end

      slim :twitter
    end
  end
end
