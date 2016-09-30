defmodule Watcher.Stats do
  @moduledoc """
  A service module for getting the various data views
  """

  @doc """
  Get an aggregated summary of all nodes
  """
  def summary(pids) do
    pids
    |> Enum.map(&ElixirTalk.stats/1)
    |> Watcher.Aggregator.summary
  end

  @doc """
  Get an aggregated tube breakdown of all nodes
  """
  def tubes(pids) do
    pids
    |> Enum.map(fn (pid) ->
      ElixirTalk.list_tubes(pid)
      |> Enum.map(fn (tube) -> ElixirTalk.stats_tube(pid, tube) end)
    end)
    |> Watcher.Aggregator.summary
  end
end
