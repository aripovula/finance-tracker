module HomeHelper
  BUDGET_STATUS_COLORS = { critical: "#dc2626", warning: "#ca8a04", good: "#16a34a" }.freeze
  CATEGORY_SERIES_COLORS = [ "#4f46e5", "#f97316", "#0d9488", "#db2777", "#0284c7", "#9ca3af" ].freeze

  def budget_status_color(status)
    BUDGET_STATUS_COLORS.fetch(status, "#6b7280")
  end

  def category_series_color(index)
    CATEGORY_SERIES_COLORS[index] || CATEGORY_SERIES_COLORS.last
  end

  # Rounds only the top two corners, so stacked segments below it stay flush.
  def rounded_top_bar_path(x:, y:, width:, height:, radius: 4)
    r = [ radius, width / 2.0, height ].min

    [
      "M #{x + r},#{y}",
      "H #{x + width - r}",
      "A #{r},#{r} 0 0 1 #{x + width},#{y + r}",
      "V #{y + height}",
      "H #{x}",
      "V #{y + r}",
      "A #{r},#{r} 0 0 1 #{x + r},#{y}",
      "Z"
    ].join(" ")
  end

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
