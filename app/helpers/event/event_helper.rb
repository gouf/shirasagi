# coding: utf-8
module Event::EventHelper
  require "holiday_japan"

  def t_date(name)
    t("datetime.prompts.#{name}")
  end

  def t_wday(date)
    t("date.abbr_day_names")[date.wday]
  end

  def event_h1_class(month)
    %w(jan feb mar apr may jun jul aug sep oct nov dec)[month - 1]
  end

  def event_dl_class(date)
    cls = %w(sun mon tue wed thu fri sat)[date.wday]
    date.national_holiday? ? "#{cls} holiday" : cls
  end

  def within_one_year?(date)
    # get current date and change day to 1
    current = Date.current.change(day: 1)

    # manipulate year from current date
    start_date = current.advance(years: -1)
    close_date = current.advance(years:  1, month: 1)

    date.between?(start_date, close_date)
  end

  def link_to_prev_month
    if @month != 1
      if within_one_year?(Date.new(@year, @month - 1, 1))
        link_to "#{@month - 1}#{t_date('month')}",
          "#{@cur_node.url}#{'%04d' % @year}#{'%02d' % (@month - 1)}.html"
      else
        "#{@month - 1}#{t_date('month')}"
      end
    else
      if within_one_year?(Date.new(@year - 1, 12, 1))
        link_to "12#{t_date('month')}", "#{@cur_node.url}#{'%04d' % (@year - 1)}12.html"
      else
        "12#{t_date('month')}"
      end
    end
    step_month_to(:prev)
  end

  def link_to_next_month
    if @month != 12
      if within_one_year? Date.new(@year, @month + 1, 1)
        link_to "#{@month + 1}#{t_date('month')}",
          "#{@cur_node.url}#{'%04d' % @year}#{'%02d' % (@month + 1)}.html"
      else
        "#{@month + 1}#{t_date('month')}"
      end
    else
      if within_one_year? Date.new(@year + 1, 1, 1)
        link_to "1#{t_date('month')}", "#{@cur_node.url}#{'%04d' % (@year + 1)}01.html"
      else
        "1#{t_date('month')}"
      end
    end
    step_month_to(:next)
  private

  def step_month_to(step_to)

    year, month, day = @year, @month, 1
    year_step, month_step = step_value(step_to)

    date = Date.new(year + year_step, month + month_step, day)
    if within_one_year?(date)
      text = "#{month + month_step}#{t_date('month')}"

      path = "#{@cur_node.url}"
      path << "#{'%04d' % (year + year_step)}"
      path << "#{'%02d' % (month + month_step)}.html"

      link_to(text, path)
    else
      "#{month + month_step}#{t_date('month')}"
    end
  end

  def step_value(step_to)
    month_step = {
      next:  1,
      prev: -1
    }[step_to]
    year_step = month_step

    # the following cases, need to manipulate both the year and month.
    #   a. month is  1 and :prev
    #   b. month is 12 and :next
    # in otherwise, it will be normal (just a manipulate month) processing.
    month = @month
    condition = (month == 1  && step_to == :prev) ||
                (month == 12 && step_to == :next)
    if condition
      month = {'12' => 1, '1' => 12}[month.to_s]
      month_step = 0
    else
      # not in edge of month, no need to step year
      year_step = 0
    end

    [year_step, month_step]
  end
end
