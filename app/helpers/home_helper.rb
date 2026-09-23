module HomeHelper
  def kpi_delta_text(current_cents, previous_cents, label: "vs last month")
    return "No data for last month" if previous_cents.blank? || previous_cents.zero?

    pct = ((current_cents - previous_cents) / previous_cents.to_f) * 100
    arrow = pct >= 0 ? "&#9650;" : "&#9660;"
    "#{arrow} #{pct.abs.round(1)}% #{label}".html_safe
  end

  def kpi_delta_class(current_cents, previous_cents, good_when: :up)
    return "text-gray-400" if previous_cents.blank? || previous_cents.zero?

    increased = current_cents >= previous_cents
    good = good_when == :up ? increased : !increased
    good ? "text-green-600" : "text-red-600"
  end
end
