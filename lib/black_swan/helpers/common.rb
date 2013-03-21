module BlackSwan::Helpers
  module Common
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

    def number_with_delimiter(number)
      parts = number.to_s.to_str.split(".")
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{","}")
      parts.join(".")
    end
  end
end
