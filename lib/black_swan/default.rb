module BlackSwan
  class Default < Sinatra::Base
    register ErrorHandling

    configure do
      set :views, "#{Config.root}/views"
    end

    get "/" do
      redirect to("/twitter")
    end

    not_found do
      slim :"errors/404"
    end
  end
end
