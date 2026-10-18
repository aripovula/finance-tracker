import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["radio", "username", "password"]

  connect() {
    this.apply(this.radioTargets.find((radio) => radio.checked))
  }

  select(event) {
    this.apply(event.target)
  }

  apply(radio) {
    if (!radio) return

    this.usernameTarget.value = radio.value
    this.passwordTarget.value = radio.dataset.password
  }
}
