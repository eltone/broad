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

  def handle_call({:cmd, cmd}, _from, %{beanstalks: pids} = state) do
    agg_stats = pids
    |> Enum.map(&ElixirTalk.Connect.call(&1, format_args(cmd)))
    |> Watcher.Aggregator.summary
    {:reply, agg_stats, state}
  end

  defp format_args([cmd | []]), do: String.to_atom(cmd)
  defp format_args([cmd | opts]), do: List.to_tuple([String.to_atom(cmd) | opts])
end
