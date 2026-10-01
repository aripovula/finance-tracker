module ApplicationHelper
  # Each icon is a minimal hand-drawn path (no icon library dependency,
  # matching how the dashboard's charts are hand-rolled inline SVG too) with
  # its own accent color, so the sidebar reads as a set of distinct
  # destinations rather than a plain text list.
  NAV_ICONS = {
    dashboard: [ "text-indigo-500", <<~SVG.strip ],
      <rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>
    SVG
    categories: [ "text-purple-500", <<~SVG.strip ],
      <path d="M3 7.5v4.19c0 .4.16.78.44 1.06l8.3 8.3c.59.58 1.53.58 2.12 0l6.5-6.5c.58-.59.58-1.53 0-2.12l-8.3-8.3A1.5 1.5 0 0 0 11.3 3H6.5A3.5 3.5 0 0 0 3 6.5"/><circle cx="7.5" cy="7.5" r="1.25" fill="currentColor" stroke="none"/>
    SVG
    budgets: [ "text-emerald-500", <<~SVG.strip ],
      <rect x="2.5" y="6" width="19" height="13" rx="2.5"/><path d="M2.5 10h19"/><circle cx="17" cy="14.5" r="1.4" fill="currentColor" stroke="none"/>
    SVG
    bank_accounts: [ "text-blue-500", <<~SVG.strip ],
      <path d="M3 10.5 12 4l9 6.5"/><path d="M4.5 10.5v8.5M9 10.5v8.5M15 10.5v8.5M19.5 10.5v8.5"/><path d="M3 19h18"/>
    SVG
    transactions: [ "text-amber-500", <<~SVG.strip ]
      <path d="M6 3h9l3 3v15l-2.5-1.5L13 21l-2.5-1.5L8 21l-2-1.3V3Z"/><path d="M8.5 9h7M8.5 12.5h7M8.5 16h4"/>
    SVG
  }.freeze

  AVATAR_COLORS = %w[#4f46e5 #dc2626 #059669 #2563eb #7c3aed #d97706 #db2777 #0891b2].freeze

  def nav_link_class(active)
    base = "flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium"

    active ? "#{base} bg-indigo-50 text-indigo-700" : "#{base} text-gray-700 hover:bg-gray-50"
  end

  def nav_icon(name)
    color, path = NAV_ICONS.fetch(name)

    tag.svg(
      path.html_safe, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
      "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round",
      class: "h-5 w-5 shrink-0 #{color}"
    )
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
end
