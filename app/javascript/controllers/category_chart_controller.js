import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["legendItem"]

  highlight(event) {
    this.setActive(event.currentTarget.dataset.seriesIndex)
  }

  unhighlight() {
    this.setActive(null)
  }

  setActive(seriesIndex) {
    this.legendItemTargets.forEach((item) => {
      const active = item.dataset.seriesIndex === seriesIndex
      const dot = item.querySelector("[data-role='dot']")
      const label = item.querySelector("[data-role='label']")

      dot.classList.toggle("ring-2", active)
      dot.classList.toggle("ring-red-500", active)
      label.classList.toggle("font-bold", active)
      label.classList.toggle("text-blue-600", active)
    })
  }
}
