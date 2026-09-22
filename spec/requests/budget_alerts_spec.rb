require "rails_helper"

RSpec.describe "Budget alerts", type: :request do
  describe "PATCH /budget_alerts/:id" do
    it "dismisses the current user's alert" do
      post login_path, params: { email: users(:one).email, password: "password123" }

      patch budget_alert_path(budget_alerts(:one))

      expect(response).to redirect_to(root_path)
      expect(budget_alerts(:one).reload.dismissed_at).to be_present
    end

    it "redirects with an alert when the budget alert belongs to another user" do
      post login_path, params: { email: users(:two).email, password: "password123" }

      patch budget_alert_path(budget_alerts(:one))

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
      expect(budget_alerts(:one).reload.dismissed_at).to be_nil
    end
  end
end
