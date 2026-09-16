import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "row", "emptyState", "sortIcon"]

  connect() {
    this.ascending = true
  }

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

  toggleSort() {
    this.ascending = !this.ascending

    const sortedRows = [ ...this.rowTargets ].sort((a, b) => {
      const comparison = a.dataset.name.localeCompare(b.dataset.name)
      return this.ascending ? comparison : -comparison
    })

    sortedRows.forEach((row) => row.parentElement.appendChild(row))

    if (this.hasSortIconTarget) {
      this.sortIconTarget.textContent = this.ascending ? "↑" : "↓"
    }
  }
}
