defmodule Watcher.Poller do
  @moduledoc """
  Intermittently sends stats to StatsEventManager
  """

  use GenServer
  require Logger

  @interval Application.get_env(:watcher, :polling_interval, 5000)

  def start_link(pool) do
    GenServer.start_link(__MODULE__, pool)
  end

  def init(pool) do
    {:ok, _} = GenEvent.start_link(name: StatsEventManager)
    schedule_check
    {:ok, pool}
  end

  def handle_info(:check, pool) do
    stats = Watcher.Pool.cmd(["stats"], pool)
    :ok = GenEvent.notify(StatsEventManager, {:stats, stats})
    schedule_check
    {:noreply, pool}
  end

  defp schedule_check do
    Process.send_after(self(), :check, @interval)
  end
end
