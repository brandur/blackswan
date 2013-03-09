module BlackSwan
  class Twitter < Sinatra::Base
    register ErrorHandling

    configure do
      set :views, "#{Config.root}/views"
    end

    get "/twitter" do
      slim :twitter
    end
  end
end
