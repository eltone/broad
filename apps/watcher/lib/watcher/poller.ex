defmodule Watcher.Poller do
  use GenServer
  require Logger

  def start_link(beanstalk) do
    GenServer.start_link(__MODULE__, beanstalk)
  end

  def init(beanstalk) do
    timer = Process.send_after(self(), :check, 5000)
    {:ok, %{timer: timer, beanstalk: beanstalk}}
  end

  def handle_call(:check, _from, %{timer: _timer, beanstalk: beanstalk}) do
    {:ok, pid} = ElixirTalk.connect(beanstalk)
    stats = ElixirTalk.stats(pid)
    Logger.info(stats)
  end
end
