module ApplicationHelper

  def tsign
    ENV['currency_symbol']
  end

  def date_range(from_date, until_date, options = {})
    if until_date.nil? # || from_date.class == Date
      if from_date.class == Date
        return I18n.l(from_date.to_date, :format => :long)
      elsif from_date.range_time.blank?
        return I18n.l(from_date.to_date, :format => :short)
      else
        return I18n.l(from_date, :format => :long)
      end
    else
      options.symbolize_keys!
      format = options[:format] || :short
      separator = options[:separator] || "—"

      if format.to_sym == :short
        month_names = I18n.t("date.abbr_month_names")
      else
        month_names = I18n.t("date.month_names")
      end

      from_day = from_date.day
      from_month = month_names[from_date.month]
      from_year = from_date.year
      until_day = until_date.day

      if from_date.month == until_date.month
        if from_date.day == until_date.day
          if until_date.strftime("%H:%M") == from_date.strftime("%H:%M")
            if from_date.strftime("%H:%M") == "00:00"
              I18n.t("date_range.#{format}.same_day_no_time", from_day: from_date.day, from_month: from_month, year: from_date.year, start_time: from_date.strftime("%H:%M"), sep: separator, end_time: until_date.strftime("%H:%M"), :format => :long)
            else
              I18n.t("date_range.#{format}.same_day_start_time", from_day: from_date.day, from_month: from_month, year: from_date.year, start_time: from_date.strftime("%H:%M"), sep: separator, end_time: until_date.strftime("%H:%M"), :format => :long)
            end
          else
            if until_date.strftime("%H:%M") == "23:59"
              I18n.t("date_range.#{format}.same_day", from_day: from_date.day, from_month: from_month, year: from_date.year, start_time: from_date.strftime("%H:%M"), sep: separator, end_time: '???', :format => :long)
            else
              I18n.t("date_range.#{format}.same_day", from_day: from_date.day, from_month: from_month, year: from_date.year, start_time: from_date.strftime("%H:%M"), sep: separator, end_time: until_date.strftime("%H:%M"), :format => :long)
            end
          end
        elsif from_date.class == Date && until_date.class == Date
          I18n.t("date_range.#{format}.same_month_no_time", from_day: from_date.day, until_day: until_date.day, month: from_month, year: from_year, sep: separator, start_time: nil, end_time: nil)
        else
          I18n.t("date_range.#{format}.same_month", from_day: from_date.day, until_day: until_date.day, month: from_month, year: from_year, sep: separator, start_time: from_date.range_time, end_time: until_date.range_time)
        end
      else
        until_month = month_names[until_date.month]
        if from_date.year == until_date.year
          I18n.t("date_range.#{format}.different_months_same_year", from_day: from_date.day, from_month: from_month, until_day: until_date.day, until_month: until_month, year: from_year, sep: separator)
        else
          until_year = until_date.year
          I18n.t("date_range.#{format}.different_years", from_day: from_date.day, from_month: from_month, from_year: from_year, until_day: until_date.day, until_month: until_month, until_year: until_year, sep: separator)
        end
      end
    end
  end


end
