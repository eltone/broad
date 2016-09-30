# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [:console],
  level: :info,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

config :watcher,
  node_repo: Watcher.EnvNodeRepo
