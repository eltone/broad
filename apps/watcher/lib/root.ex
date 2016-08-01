defmodule Root do
  use Supervisor

  @moduledoc """
  The beanstalk pool root supervisor
  """

  @name Watcher.RootSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init do
    children = [
      worker(Poller, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)

    Supervisor.start_child(@name, ["127.0.0.1:11300"])
  end

  @doc """
  Send a command to every beanstalk
  """
  def send_command do
  
  end
end
