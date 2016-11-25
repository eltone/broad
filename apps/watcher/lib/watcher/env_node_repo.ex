defmodule Watcher.EnvNodeRepo do
  @moduledoc """
  Env var beanstalk server list repo
  """

  def get do
    "BEANSTALKS"
    |> System.get_env
    |> String.split
  end
end
