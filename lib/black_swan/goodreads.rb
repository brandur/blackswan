module BlackSwan
  class Goodreads < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Goodreads
    register ErrorHandling

    configure do
      set :views, "#{Config.root}/views"
    end

    get "/books" do
      redirect to("/reading")
    end

    get "/reading" do
      @title = "Reading"

      @books = DB[:events].filter(type: "goodreads").
        reverse_order(:occurred_at)

      last_modified(@books.first[:occurred_at])

      @books_count   = @books.count
      @books_by_year = @books.all.group_by { |b| b[:occurred_at].year }

      @book_count_by_year = {}
      @page_count_by_year = {}
      @books.reverse.each do |b|
        year = Time.new(b[:occurred_at].year)

        @book_count_by_year[year] ||= 0
        @book_count_by_year[year] += 1

        @page_count_by_year[year] ||= 0
        @page_count_by_year[year] += b[:metadata][:num_pages].to_i
      end

      slim :goodreads
    end
  end
end
