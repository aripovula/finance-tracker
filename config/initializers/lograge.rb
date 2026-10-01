# One structured JSON log line per request (method, path, status, duration,
# request_id) instead of Rails' multi-line default - the "structured JSON
# logs with a request correlation ID" item from CLAUDE.md's tech stack.
#
# Enabled in every environment, including test and development, not just
# production: this app has no deployment yet (see CLAUDE.md §9), so gating
# it to production would mean it's never actually observed. Request specs
# verify the format directly (spec/requests/lograge_spec.rb); in
# development/production it writes to the same logger production.rb already
# points at STDOUT.
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    { request_id: event.payload[:headers]["action_dispatch.request_id"] }
  end
end
