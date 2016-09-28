defmodule Watcher.Aggregator do

  @moduledoc """
  Functions for getting statistic from a collection of beanstalkd servers
  """

  @doc """
  Get the aggregate server stats of all nodes
  """

  def summary(beanstalks) do
    beanstalks
    |> Enum.map(&parse_connection/1)
    |> Enum.map(&node_summary/1)
    |> Enum.reduce(%{}, &Map.merge(&1, &2, fn (k, v1, v2) -> merge_node(k, v1, v2) end))
    |> Enum.sort
  end

  defp node_summary(beanstalk) do
    {:ok, pid} = ElixirTalk.connect(beanstalk)
    res = ElixirTalk.stats(pid)
    ElixirTalk.quit(pid)
    res
  end

  defp parse_connection(beanstalk) do
    case String.split(beanstalk, ":") do
      [host, port] -> [host: to_charlist(host), port: parse_port(port)]
      [host] -> [host: to_charlist(host)]
    end
  end

  defp parse_port(port_string) do
    {port, ""} = Integer.parse(port_string)
    port
  end

  @unsummable_keys ~w(uptime rusage-utime binlog-current-index max-job-size version rusage-stime
    binlog-oldest-index pid binlog-max-size)

  defp merge_node(k, _v1, v2) when k in @unsummable_keys, do: v2

  defp merge_node(_k, v1, v2) when is_number(v1) and is_number(v2) do
    v1 + v2
  end

  defp merge_node(_k, _v1, _v2), do: "n/a"
end
