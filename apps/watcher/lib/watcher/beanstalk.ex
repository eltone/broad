defmodule Watcher.Beanstalk do
  @moduledoc """
  Contains functions for setting up beanstalkd connections
  """

  def parse_connection(beanstalk) do
    case String.split(beanstalk, ":") do
      [host, port] -> [host: to_charlist(host), port: parse_port(port)]
      [host] -> [host: to_charlist(host), port: 11300]
    end
  end

  def run_and_close(beanstalk_conn, callback) do
    {:ok, pid} = ElixirTalk.connect(beanstalk_conn)
    res = callback.(pid)
    ElixirTalk.quit(pid)
    res
  end

  def parse_and_connect(beanstalk) do
    {:ok, pid} = beanstalk
    |> parse_connection
    |> ElixirTalk.connect
    pid
  end

  defp parse_port(port_string) do
    {port, ""} = Integer.parse(port_string)
    port
  end
end
