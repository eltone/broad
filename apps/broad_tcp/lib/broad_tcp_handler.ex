defmodule BroadTcp.Handler do
  @moduledoc """
  Ranch handler for incoming beanstalkd commands
  """

  require Logger

  def start_link(ref, socket, transport, opts) do
    Task.start_link(__MODULE__, :init, [ref, socket, transport, opts])
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, 60_000) do
      {:ok, data} ->
        res = data
        |> String.split
        |> parse
        transport.send(socket, res)
        loop(socket, transport)
      {:error, :closed} ->
        Logger.info("connection closed")
        :ok = transport.close(socket)
      {:error, reason} ->
        Logger.error("receive error #{reason}")
        :ok = transport.close(socket)
    end
  end

  @supported_commands ~w(stats stats-tube delete peek peek-ready peek-delayed peek-buried kick
    kick-job stats-job list-tubes list-tube-used list-tubes-watched)

  defp parse([cmd | _opts] = input) when cmd in @supported_commands do
    yaml = input
    |> Watcher.Pool.cmd
    |> format
    line_with_yaml = ["---\n", yaml]
    res_length = IO.iodata_length(line_with_yaml)
    ["OK ", to_string(res_length), "\r\n", line_with_yaml, "\r\n"]
  end

  defp parse(_input) do
    "UNKNOWN_COMMAND\r\n"
  end

  defp format(enum) when is_map(enum) do
    enum
    |> Enum.map(fn ({k,v}) -> [k, ": ", to_string(v), "\n"] end)
  end

  defp format(enum) when is_list(enum) do
    enum
    |> Enum.map(fn (x) -> ["- ", to_string(x), "\n"] end)
  end
end
