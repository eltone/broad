defmodule Watcher.Pool do
  @moduledoc """
  Maintains connections to a pool of beanstalkd servers
  """

  use GenServer

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

  @aggregate_commands ~w(stats stats-tube)
  @union_commands ~w(list-tubes list-tubes-watched)

  def handle_call({:cmd, cmd}, _from, %{beanstalks: pids} = state) do
    agg_stats = pids
    |> Enum.map(&ElixirTalk.Connect.call(&1, format_args(cmd)))
    |> aggregate(cmd)
    {:reply, agg_stats, state}
  end

  defp format_args([cmd | []]), do: String.to_atom(cmd)
  defp format_args([cmd | opts]), do: List.to_tuple([String.to_atom(cmd) | opts])

  defp aggregate(enum, [cmd | _opts]) when cmd in @aggregate_commands do
    Watcher.Aggregator.summary(enum)
  end

  defp aggregate(enum, [cmd | _opts]) when cmd in @union_commands do
    Watcher.Aggregator.union(enum)
  end
end
