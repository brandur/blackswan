require 'digest/sha1'

module BlackSwan::Helpers
  module Twitter
    def content_to_html(content)
      html    = content.dup
      tag_map = {}

      # links like protocol://link
      html.gsub! /(^|[\n ])([\w]+?:\/\/[\w]+[^ "\n\r\t< ]*)/ do
        display = $2.length > 30 ? "#{$2[0..30]}&hellip;" : $2

        # replace with tags so links don't interfere with subsequent rules
        tag = Digest::SHA1.hexdigest($2)
        tag_map[tag] = %{<a href="#{$2}" rel="nofollow">#{display}</a>}

        # make sure to preserve whitespace before the inserted tag
        "#{$1}#{tag}"
      end

      # links like www.link.com or ftp.link.com
      html.gsub! /(^|[\n ])((www|ftp)\.[^ "\t\n\r< ]*)/,
        '\1<a href="http://\2" rel="nofollow">\2</a>'

      # user links (like @brandur)
      html.gsub! /@(\w+)/,
        '<a href="https://www.twitter.com/\1" rel="nofollow">@\1</a>'

      # hash tag search (like #mix11)
      html.gsub! /#(\w+)/,
        '<a href="https://search.twitter.com/search?q=\1" rel="nofollow">#\1</a>'

      # replace links generated earlier
      tag_map.each do |tag, replacement|
        html.sub! tag, replacement
      end

      html
    end

    def month_name(month_number)
      Time.new(2000, month_number).strftime('%B')
    end
  end
end
