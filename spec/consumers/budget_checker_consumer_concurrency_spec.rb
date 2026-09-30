require "rails_helper"

# Proves the guarantee CLAUDE.md §3 describes: "no race condition between
# concurrent transaction-processing jobs." A real Karafka deployment runs
# several consumer threads against the same process, so if a burst of
# transactions all push the same user/category over budget at once, several
# threads can reach the throttle check at nearly the same instant. Only
# Redis's atomic SET NX EX - not a Ruby-level lock - decides who wins.
RSpec.describe "BudgetCheckerConsumer alert throttle under concurrency" do
  let(:user) { users(:one) }
  let(:category) { categories(:dining) }
  let(:consumer) { BudgetCheckerConsumer.new }

  before { AppRedis.client.flushdb }

  it "lets exactly one of many simultaneous attempts win the throttle for the same user/category/day" do
    results = Array.new(20)

    threads = Array.new(20) do |i|
      Thread.new { results[i] = consumer.send(:throttle!, user, category) }
    end
    threads.each(&:join)

    expect(results.count { |won| won }).to eq(1)
  end

  it "still lets a new day's burst through once the previous day's key has expired" do
    expect(consumer.send(:throttle!, user, category)).to be(true)

    travel_to(1.day.from_now) do
      results = Array.new(10)
      threads = Array.new(10) { |i| Thread.new { results[i] = consumer.send(:throttle!, user, category) } }
      threads.each(&:join)

      expect(results.count { |won| won }).to eq(1)
    end
  end
end
