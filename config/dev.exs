import Config

# Configure your database
config :huge_seller, HugeSeller.Repo,
  url: System.get_env("DATABASE_URL"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

# Configures Elasticsearch
config :huge_seller, HugeSeller.ElasticCluster,
  url: System.get_env("ELASTICSEARCH_URL"),
  username: System.get_env("ELASTICSEARCH_USERNAME"),
  password: System.get_env("ELASTICSEARCH_PASSWORD")

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
