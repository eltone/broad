defmodule Watcher.Pool do
  use GenServer
  @moduledoc """
  Maintains connections to a pool of beanstalkd servers
  """


  def start_link(name, beanstalks) do
    GenServer.start_link(__MODULE__, beanstalks, [name: name])
  end

  def init(beanstalks) do
    pids = beanstalks
    |> Enum.map(&Watcher.Beanstalk.parse_and_connect/1)
    {:ok, %{beanstalks: pids}}
  end

  # Client

  @doc """
  Send a command to all beanstalk nodes
  """
  def cmd(cmd, pid \\ __MODULE__) do
    GenServer.call(pid, {:cmd, cmd})
  end

  # Server

  def handle_call({:cmd, :stats}, _from, %{beanstalks: pids} = state) do
    agg_stats = Watcher.Stats.summary(pids)
    {:reply, agg_stats, state}
  end
end
