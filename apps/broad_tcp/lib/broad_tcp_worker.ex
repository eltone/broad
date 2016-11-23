defmodule BroadTcp.Worker do
  def start_link do
    opts = [port: 11301]
    {:ok, _} = :ranch.start_listener(:broad_tcp, 10, :ranch_tcp, opts, BroadTcp.Handler, [])
  end
end
