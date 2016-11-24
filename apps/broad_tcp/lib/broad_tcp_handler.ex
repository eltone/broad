defmodule BroadTcp.Handler do
  require Logger

  def start_link(ref, socket, transport, opts) do
    Task.start_link(__MODULE__, :init, [ref, socket, transport, opts])
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    case transport.recv(socket, 0, 60000) do
      {:ok, data} ->
        res = data
        |> String.split
        |> parse
        transport.send(socket, res)
        loop(socket, transport)
      {:error, reason} ->
        Logger.error("receive error #{reason}")
        :ok = transport.close(socket)
    end
  end

  defp parse(["stats"]) do
    Watcher.Pool.cmd(:stats)
    |> format
  end

  defp parse(["stats-tube", tube_name]) do
    Logger.info("hey! " <> tube_name)
  end

  defp format(map) do
    map
    |> Enum.map(fn ({k,v}) -> [k, ": ", to_string(v), "\r\n"] end)
  end
end
