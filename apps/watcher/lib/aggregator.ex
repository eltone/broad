defmodule Watcher.Aggregator do

  @moduledoc """
  Functions for getting statistic from a collection of beanstalkd servers
  """

  @doc """
  Get the aggregate server stats of all nodes
  """
  def summary(beanstalks, callback) do
    beanstalks
    |> Enum.map(callback)
    |> Enum.reduce(%{}, &Map.merge(&1, &2, fn (k, v1, v2) -> merge_node(k, v1, v2) end))
    |> Enum.sort
  end

  @unsummable_keys ~w(uptime rusage-utime binlog-current-index max-job-size version rusage-stime
    binlog-oldest-index pid binlog-max-size)

  defp merge_node(k, _v1, v2) when k in @unsummable_keys, do: v2

  defp merge_node(_k, v1, v2) when is_number(v1) and is_number(v2) do
    v1 + v2
  end

  defp merge_node(_k, _v1, _v2), do: "n/a"
end
