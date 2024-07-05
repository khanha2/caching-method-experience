import Config

# Configure your database
config :huge_seller, HugeSeller.Repo,
  url: System.get_env("DATABASE_URL"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 5

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
