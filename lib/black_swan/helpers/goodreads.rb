module BlackSwan::Helpers
  module Goodreads
    def format_isbn13(isbn)
      if isbn.length == 13
        isbn[0..2] + "-" + isbn[3] + "-" + isbn[4..6] +
          "-" + isbn[7..11] + "-" + isbn[12]
      else
        nil
      end
    end
  end
end
