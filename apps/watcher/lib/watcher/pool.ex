defmodule Watcher.Pool do
  @moduledoc """
  Maintains connections to a pool of beanstalkd servers
  """

  use GenServer

  def start_link(name, beanstalks) do
    GenServer.start_link(__MODULE__, beanstalks, [name: name])
  end

  defmodule State do
    @moduledoc """
    Genserver state
    """
    defstruct beanstalks: [], using: "default", peek_buffer: []
  end

  def init(beanstalks) do
    pids = beanstalks
    |> Enum.map(&Watcher.Beanstalk.parse_and_connect/1)
    {:ok, %State{beanstalks: pids}}
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
  @buffered_commands ~w(peek-delayed peek-buried)

  def handle_call({:cmd, ["use", tube]}, _from, %State{beanstalks: pids} = state) do
    pids
    |> Enum.each(&ElixirTalk.use(&1, tube))
    {:reply, {:message, "USING #{tube}"}, %{state | using: tube, peek_buffer: []}}
  end

  def handle_call({:cmd, [cmd | _opts]}, _from, state) when cmd in @buffered_commands do
    {head, new_state} = peek(state, cmd)
    # TODO: handle case where tube is empty
    {:found, id, body} = head
    {:reply, {:job, {id, body}}, new_state}
  end

  def handle_call({:cmd, cmd}, _from, %State{beanstalks: pids} = state) do
    agg_stats = pids
    |> Enum.map(&ElixirTalk.Connect.call(&1, format_args(cmd)))
    |> aggregate(cmd)
    {:reply, {:yaml, agg_stats}, state}
  end

  defp format_args([cmd | []]), do: String.to_atom(cmd)
  defp format_args([cmd | opts]), do: List.to_tuple([String.to_atom(cmd) | opts])

  defp aggregate(enum, [cmd | _opts]) when cmd in @aggregate_commands do
    Watcher.Aggregator.summary(enum)
  end

  defp aggregate(enum, [cmd | _opts]) when cmd in @union_commands do
    Watcher.Aggregator.union(enum)
  end

  defp peek(%State{beanstalks: pids, peek_buffer: []} = state, cmd) do
    [head | _] = res = fetch(cmd, pids)
    {head, %{state | peek_buffer: res}}
  end

  defp peek(%State{peek_buffer: [head | _]} = state, _cmd), do: {head, state}

  defp fetch(cmd, pids) do
    pids
    |> Enum.map(&ElixirTalk.Connect.call(&1, format_args([cmd])))
  end
end
