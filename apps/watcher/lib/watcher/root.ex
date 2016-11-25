defmodule Watcher.Root do
  @moduledoc """
  The beanstalk pool root supervisor
  """

  use Supervisor

  @name Watcher.Root

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(_args) do
    beanstalks = ["127.0.0.1:11300"]
    children = [
      worker(Watcher.Pool, [Watcher.Pool, beanstalks], restart: :permanent),
      worker(Watcher.Poller, [Watcher.Pool], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end

  @doc """
  Send a command to every beanstalk
  """
  def send_command do
  end
end
