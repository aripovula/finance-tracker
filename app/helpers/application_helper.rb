module ApplicationHelper
  # Each icon is a minimal hand-drawn path (no icon library dependency,
  # matching how the dashboard's charts are hand-rolled inline SVG too).
  # Shared between the sidebar nav (small, colorful) and empty states
  # (larger, muted) via nav_icon/empty_state_icon below, so the same shape
  # means the same thing everywhere in the app.
  ICON_PATHS = {
    dashboard: <<~SVG.strip,
      <rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>
    SVG
    categories: <<~SVG.strip,
      <path d="M3 7.5v4.19c0 .4.16.78.44 1.06l8.3 8.3c.59.58 1.53.58 2.12 0l6.5-6.5c.58-.59.58-1.53 0-2.12l-8.3-8.3A1.5 1.5 0 0 0 11.3 3H6.5A3.5 3.5 0 0 0 3 6.5"/><circle cx="7.5" cy="7.5" r="1.25" fill="currentColor" stroke="none"/>
    SVG
    budgets: <<~SVG.strip,
      <rect x="2.5" y="6" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><circle cx="17" cy="14.5" r="1.4" fill="currentColor" stroke="none"/>
    SVG
    bank_accounts: <<~SVG.strip,
      <path d="M3 10.5 12 4l9 6.5"/><path d="M4.5 10.5v8.5M9 10.5v8.5M15 10.5v8.5M19.5 10.5v8.5"/><path d="M3 19h18"/>
    SVG
    transactions: <<~SVG.strip,
      <path d="M6 3h9l3 3v15l-2.5-1.5L13 21l-2.5-1.5L8 21l-2-1.3V3Z"/><path d="M8.5 9h7M8.5 12.5h7M8.5 16h4"/>
    SVG
    chart: <<~SVG.strip,
      <path d="M4 19V10M10 19V5M16 19V13M22 19V8"/>
    SVG
    search: <<~SVG.strip
      <circle cx="10" cy="10" r="6.5"/><path d="M19 19l-4.35-4.35"/>
    SVG
  }.freeze

  NAV_COLORS = {
    dashboard: "text-indigo-500", categories: "text-purple-500", budgets: "text-emerald-500",
    bank_accounts: "text-blue-500", transactions: "text-amber-500"
  }.freeze

  AVATAR_COLORS = %w[#4f46e5 #dc2626 #059669 #2563eb #7c3aed #d97706 #db2777 #0891b2].freeze

  def nav_link_class(active)
    base = "flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium"

    active ? "#{base} bg-indigo-50 text-indigo-700" : "#{base} text-gray-700 hover:bg-gray-50"
  end

  def nav_icon(name)
    icon(name, css_class: "h-5 w-5 shrink-0 #{NAV_COLORS.fetch(name)}", stroke_width: 2)
  end

  # A muted icon inside a soft circle, for an empty table/chart/list - paired
  # with a short explanation via empty_state below.
  def empty_state_icon(name)
    content_tag(:div, icon(name, css_class: "h-6 w-6 text-gray-400", stroke_width: 1.5),
      class: "flex h-12 w-12 items-center justify-center rounded-full bg-gray-100")
  end

  def empty_state(icon_name, &block)
    content_tag(:div, class: "flex flex-col items-center gap-3 px-6 py-10 text-center") do
      concat(empty_state_icon(icon_name))
      concat(content_tag(:p, capture(&block), class: "max-w-xs text-sm text-gray-500"))
    end
  end

  # A consistent color per name (e.g. "Chase" is always the same blue) so an
  # avatar doesn't visually flicker between renders, without needing to
  # store a color anywhere - the same approach the dashboard's category
  # chart already uses for its series colors.
  def avatar_color(name)
    AVATAR_COLORS[name.to_s.sum % AVATAR_COLORS.size]
  end

  def avatar_initial(name)
    name.to_s.strip[0]&.upcase || "?"
  end

  private

  def icon(name, css_class:, stroke_width:)
    tag.svg(
      ICON_PATHS.fetch(name).html_safe, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
      "stroke-width": stroke_width, "stroke-linecap": "round", "stroke-linejoin": "round", class: css_class
    )
  end
end
