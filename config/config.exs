import Config

config :huge_seller,
  ecto_repos: [HugeSeller.Repo]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Elasticsearch
config :huge_seller, HugeSeller.ElasticCluster,
  api: Elasticsearch.API.HTTP,
  default_options: [
    timeout: :timer.minutes(1),
    recv_timeout: :timer.minutes(1),
    hackney: [pool: :huge_seller]
  ],
  json_library: Jason

# Use Jason for JSON parsing in Phoenix
# config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
