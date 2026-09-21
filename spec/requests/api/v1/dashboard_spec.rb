require "swagger_helper"

RSpec.describe "api/v1/dashboard", type: :request do
  path "/api/v1/dashboard/monthly_summary" do
    get "Returns the current user's monthly spending by category" do
      tags "Dashboard"
      security [ bearerAuth: [] ]
      produces "application/json"
      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :month, in: :query, type: :string, required: false

      response "200", "monthly summary returned" do
        let(:Authorization) { "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }
        let(:month) { monthly_summaries(:one).month.strftime("%Y-%m") }

        run_test! do |response|
          data = JSON.parse(response.body)["data"]
          expect(data.first["category_name"]).to eq(categories(:dining).name)
          expect(data.first["total_spent_cents"]).to eq(monthly_summaries(:one).total_spent_cents)
        end
      end

      response "401", "missing or invalid token" do
        let(:Authorization) { "Bearer not-a-real-token" }

        run_test!
      end
    end
  end

  describe "ETag caching" do
    it "returns 304 when If-None-Match matches the current ETag" do
      headers = { "Authorization" => "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }
      month = monthly_summaries(:one).month.strftime("%Y-%m")

      get "/api/v1/dashboard/monthly_summary", params: { month: month }, headers: headers
      etag = response.headers["ETag"]
      expect(etag).to be_present

      get "/api/v1/dashboard/monthly_summary", params: { month: month }, headers: headers.merge("If-None-Match" => etag)

      expect(response).to have_http_status(:not_modified)
    end

    it "returns a fresh 200 after the underlying summary changes" do
      headers = { "Authorization" => "Bearer #{AuthTokenService.new.issue_tokens(users(:one))[:access_token]}" }
      month = monthly_summaries(:one).month.strftime("%Y-%m")

      get "/api/v1/dashboard/monthly_summary", params: { month: month }, headers: headers
      etag = response.headers["ETag"]

      monthly_summaries(:one).update!(total_spent_cents: monthly_summaries(:one).total_spent_cents + 100)

      get "/api/v1/dashboard/monthly_summary", params: { month: month }, headers: headers.merge("If-None-Match" => etag)

      expect(response).to have_http_status(:ok)
    end
  end
end
