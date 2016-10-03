defmodule Watcher.Poller do
  use GenServer
  require Logger

  def start_link(beanstalks) do
    GenServer.start_link(__MODULE__, beanstalks)
  end

  def init(beanstalks) do
    pids = beanstalks
    |> Enum.map(&Watcher.Beanstalk.parse_and_connect/1)
    schedule_check
    {:ok, %{beanstalks: pids}}
  end

  def handle_info(:check, %{beanstalks: beanstalks} = state) do
    stats = beanstalks
    |> Watcher.Stats.summary
    Logger.info("got some stats yo: #{inspect(stats)}")
    schedule_check
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check, 5000)
  end
end
