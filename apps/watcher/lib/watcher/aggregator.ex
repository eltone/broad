defmodule Watcher.Aggregator do

  @moduledoc """
  Functions for getting statistic from a collection of beanstalkd servers
  """

  @doc """
  Get the aggregate server stats of all nodes
  """
  def summary(enumerable) do
    enumerable
    |> Enum.reduce(%{}, &merge_type/2)
  end

  @unsummable_keys ~w(uptime rusage-utime binlog-current-index max-job-size version rusage-stime
    binlog-oldest-index pid binlog-max-size)

  defp merge_type(enum, acc) when is_map(enum) do
    Map.merge(enum, acc, fn (k, v1, v2) -> merge_node(k, v1, v2) end)
  end

  defp merge_type(enum, acc) when is_list(enum) do
    # assume list of maps for now TODO: can this be tested with a match?
    enum
    |> Enum.into(%{}, fn (tube) -> {tube["name"], Map.drop(tube, ["name"])} end)
    |> merge_type(acc)
  end

  defp merge_node(k, _v1, v2) when k in @unsummable_keys, do: v2

  defp merge_node(_k, v1, v2) when is_map(v1) and is_map(v2), do: merge_type(v1, v2)

  defp merge_node(_k, v1, v2) when is_number(v1) and is_number(v2) do
    v1 + v2
  end

  defp merge_node(_k, _v1, _v2), do: "n/a"
end
