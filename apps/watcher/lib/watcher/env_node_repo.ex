defmodule Watcher.EnvNodeRepo do
  def get do
    System.get_env("BEANSTALKS")
    |> String.split
  end
end
