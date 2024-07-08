import Config

config :huge_seller, HugeSeller.ElasticCluster,
  url: System.get_env("ELASTICSEARCH_URL"),
  username: System.get_env("ELASTICSEARCH_USERNAME"),
  password: System.get_env("ELASTICSEARCH_PASSWORD")

# config :huge_seller_api, HugeSellerApi.Endpoint, server: true

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :huge_seller, HugeSeller.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6
end
