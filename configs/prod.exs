import Config

# Do not print debug messages in production
config :logger, level: :info

# Configures Log timestamp to be in UTC
config :logger, utc_log: true
