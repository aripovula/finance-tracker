import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row", "emptyState"]

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.rowTargets.forEach((row) => {
      const matches = row.dataset.name.includes(query)
      row.hidden = !matches
      if (matches) visibleCount++
    })

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.hidden = visibleCount !== 0
    }
  }
}
