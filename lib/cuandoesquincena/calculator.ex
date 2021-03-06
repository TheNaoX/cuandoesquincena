defmodule Cuandoesquincena.Calculator do
  use Timex
  #seconds within a day 60 * 60 * 24
  @seconds_in_day 86400
  #the weekend starts at the sat(6)
  @weekend_start_at 6
  # more or less days that paypal takes to move your money to the bank account IN MEXICO
  @average_paypal_delay 3

  def is_today? do
    days_until == 0
  end

  def is_today_paypal? do
    days_until_paypal == 0
  end

  def days_until, do: div seconds_until, @seconds_in_day
  def days_until_paypal, do: div seconds_until_paypal, @seconds_in_day

  def weekends do
    Interval.new(from: past_real_paydate, until: next_real_paydate)
    |> Enum.map(fn(d) -> Timex.weekday(d) end)
    |> Enum.filter(fn(d) -> d == @weekend_start_at end)
    |> Enum.count
  end

  def seconds_until do
     next_real_paydate |> Timex.to_datetime |> Timex.diff(Timex.local,  :seconds)
  end

  def seconds_until_paypal do
    next_paypal_paydate |> Timex.to_datetime |> Timex.diff(Timex.local,  :seconds)
  end

  def last_canonical_paydate(%Date{day: day} = canonical) when day >= 15,
    do: Timex.beginning_of_month(canonical)

  def last_canonical_paydate(%Date{day: day, month: month} = canonical) when day < 15,
    do: fix_year(canonical) |> Timex.end_of_month

  def fix_year(%Date{day: day, month: month, year: year} = payday) when month == 1 do
    %{payday | year: year - 1, month: 12}
  end

  def fix_year(%Date{day: day, month: month, year: year} = payday) when month > 1 do
    %{payday | month: month - 1}
  end

  def next_real_paydate do
    %Date{year: year, month: month, day: day} = next_date = today |> next_canonical_payday_from_today |> fix_workday
    %Date{day: tday} = today

    if tday > day do
      next_canonical_payday_from_today(%{next_date | day: 16}) |> fix_workday
    else
      next_date
    end
  end

  def next_paypal_paydate do
    %Date{day: day, month: month, year: year} = next_real_paydate
    %Date{day: day - @average_paypal_delay, month: month, year: year} |> fix_workday
  end

  def past_real_paydate do
    %Date{year: year, month: month, day: day} = next_date = today |> next_canonical_payday_from_today |> fix_workday
    %Date{day: tday} = today

    if tday > day do
      last_canonical_paydate(%{next_date | day: 16}) |> next_canonical_payday_from_today |> fix_workday
    else
      today |> last_canonical_paydate |> next_canonical_payday_from_today |> fix_workday
    end
  end

  def today, do: Timex.local |> Timex.to_date

  def fix_workday(%Date{day: day} = canonical) do
    %{canonical | day: Timex.weekday(canonical) |> weekend(day) }
  end

  def next_canonical_payday_from_today(%Date{year: year, month: month, day: day} = payday)
  when day >= 15 do
    %{payday | day: :calendar.last_day_of_the_month(year, month) }
  end

  def next_canonical_payday_from_today(payday) do
    %{payday | day: 15}
  end


  def weekend(wday, day) when wday == 7, do: day - 2
  def weekend(wday, day) when wday == 6, do: day - 1
  def weekend(_, day), do: day
end
