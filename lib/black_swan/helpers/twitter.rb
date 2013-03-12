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
        tag_map[tag] = %{#{$1}<a href="#{$2}" rel="nofollow">#{display}</a>}
        tag
      end

      # links like www.link.com or ftp.link.com
      html.gsub! /(^|[\n ])((www|ftp)\.[^ "\t\n\r< ]*)/,
        '\1<a href="http://\2" rel="nofollow">\2</a>'

      # user links (like @brandur)
      html.gsub! /@(\w+)/,
        '<a href="https://www.twitter.com/\1" rel="nofollow">@\1</a>'

      # hash tag search (like #mix11)
    # html.gsub! /#(\w+)/,
    #   '<a href="https://search.twitter.com/search?q=\1" rel="nofollow">#\1</a>'

      # replace links generated earlier
      tag_map.each do |tag, replacement|
        html.sub! tag, replacement
      end

      html
    end

    # only works up to one year
    def distance_of_time_in_words(from_time, to_time=Time.now)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round

      case distance_in_minutes
        when 0 then "less than 1 minute"
        when 1..44 then "%s minutes" % distance_in_minutes
        when 45..89          then "about 1 hour"
        when 90..1439        then "about %s hours" %
          (distance_in_minutes.to_f / 60.0).round
        when 1440..2519      then "1 day"
        when 2520..43199     then "%s days" %
          (distance_in_minutes.to_f / 1440.0).round
        when 43200..86399    then "about 1 month"
        when 86400..525599   then "%s months" %
          (distance_in_minutes.to_f / 43200.0).round
        else nil
      end
    end

    def month_name(month_number)
      Time.new(2000, month_number).strftime('%B')
    end

    def number_with_delimiter(number)
      parts = number.to_s.to_str.split(".")
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{","}")
      parts.join(".")
    end
  end
end
