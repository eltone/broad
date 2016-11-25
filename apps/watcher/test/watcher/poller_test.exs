defmodule Watcher.PollerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, _pool_pid} = Watcher.Pool.start_link(:test_pool, ["127.0.0.1:11300"])
    {:ok, _pid} = Watcher.Poller.start_link(:test_pool)
    :ok = GenEvent.add_mon_handler(StatsEventManager, Watcher.PollerTest.Forwarder, self)
    {:ok, []}
  end

  test "sends polled events to StatsEventManager" do
    assert_receive {:stats, %{}}
  end

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end
end
