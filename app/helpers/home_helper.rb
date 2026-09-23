module HomeHelper
  BUDGET_STATUS_COLORS = { critical: "#dc2626", warning: "#ca8a04", good: "#16a34a" }.freeze
  # Alternates bright, joyful hues with darker, richer ones spread across the hue
  # wheel (rose/amber/emerald/indigo/fuchsia) so adjacent series stay distinct.
  # Excludes the blue family, which is reserved for CATEGORY_COLOR_OVERRIDES below.
  CATEGORY_SERIES_COLORS = [ "#be123c", "#f59e0b", "#10b981", "#4338ca", "#d946ef" ].freeze
  # Categories pinned to a specific color (by name) instead of their chart rank,
  # so they stay visually distinct and consistent across months.
  CATEGORY_COLOR_OVERRIDES = { "Account Transfer" => "#38bdf8", "Other" => "#57534e" }.freeze

  def budget_status_color(status)
    BUDGET_STATUS_COLORS.fetch(status, "#6b7280")
  end

  def category_series_color(name, index)
    CATEGORY_COLOR_OVERRIDES[name] || CATEGORY_SERIES_COLORS[index % CATEGORY_SERIES_COLORS.size]
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
