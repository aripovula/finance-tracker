require "rails_helper"

# Not an E2E/browser concern - there's no UI for a log line - so this is
# covered at the request-spec level instead: swap in a StringIO logger for
# the duration of one request and parse what Lograge actually wrote.
RSpec.describe "Structured request logging", type: :request do
  it "logs a single JSON line per request with method, path, status, and a request id" do
    io = StringIO.new
    test_logger = Logger.new(io)
    test_logger.formatter = proc { |_severity, _time, _progname, msg| "#{msg}\n" }

    original_logger = Lograge.logger
    Lograge.logger = test_logger

    begin
      get login_path
    ensure
      Lograge.logger = original_logger
    end

    payload = JSON.parse(io.string.lines.last)

    expect(payload).to include("method" => "GET", "path" => "/login", "status" => 200)
    expect(payload["request_id"]).to be_present
  end
end
