import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "from", "to", "row", "emptyState"]

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    const from = this.fromTarget.value
    const to = this.toTarget.value
    let visibleCount = 0

    this.rowTargets.forEach((row) => {
      const matchesQuery = row.dataset.searchText.includes(query)
      const postedAt = row.dataset.postedAt
      const afterFrom = !from || postedAt >= from
      const beforeTo = !to || postedAt <= to
      const matches = matchesQuery && afterFrom && beforeTo

      row.hidden = !matches
      if (matches) visibleCount++
    })

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.hidden = visibleCount !== 0
    }
  }
}
