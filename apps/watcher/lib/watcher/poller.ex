defmodule Watcher.Poller do
  use GenServer
  require Logger

  @interval Application.get_env(:watcher, :polling_interval, 5000)

  def start_link(beanstalks) do
    GenServer.start_link(__MODULE__, beanstalks)
  end

  def init(beanstalks) do
    pids = beanstalks
    |> Enum.map(&Watcher.Beanstalk.parse_and_connect/1)
    {:ok, _} = GenEvent.start_link(name: StatsEventManager)
    schedule_check
    {:ok, %{beanstalks: pids}}
  end

  def handle_info(:check, %{beanstalks: beanstalks} = state) do
    stats = beanstalks
    |> Watcher.Stats.summary
    :ok = GenEvent.notify(StatsEventManager, {:stats, stats})
    schedule_check
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check, @interval)
  end
end
