defmodule HugeSeller.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HugeSeller.Repo,
      # Start the cache store
      HugeSeller.LocalCache.create_connection_spec()
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HugeSeller.Supervisor)
  end
end
