defmodule Watcher.Root do
  use Supervisor

  @moduledoc """
  The beanstalk pool root supervisor
  """

  @name Watcher.Root

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(_args) do
    children = [
      worker(Watcher.Poller, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def add_pinger do
    Supervisor.start_child(@name, ["127.0.0.1:11300"])
  end

  @doc """
  Send a command to every beanstalk
  """
  def send_command do
  
  end
end
