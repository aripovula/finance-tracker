import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { linkTokenUrl: String, exchangeUrl: String }

  async connectBank() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    const linkTokenResponse = await fetch(this.linkTokenUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken, "Accept": "application/json" }
    })
    const { link_token } = await linkTokenResponse.json()

    const handler = Plaid.create({
      token: link_token,
      onSuccess: async (publicToken, metadata) => {
        const account = metadata.accounts[0]

        await fetch(this.exchangeUrlValue, {
          method: "POST",
          headers: {
            "X-CSRF-Token": csrfToken,
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify({
            public_token: publicToken,
            institution_name: metadata.institution?.name,
            account_id: account?.id,
            mask: account?.mask
          })
        })

        window.location.reload()
      }
    })

    handler.open()
  }
}
