module ApplicationHelper
  def nav_link_class(active)
    base = "block rounded-md px-3 py-2 text-sm font-medium"

    active ? "#{base} bg-indigo-50 text-indigo-700" : "#{base} text-gray-700 hover:bg-gray-50"
  end
end
