defmodule HugeSeller.MixProject do
  use Mix.Project

  def project do
    [
      app: :huge_seller,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HugeSeller.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cachex, "~> 3.6"},
      {:ecto_sql, "~> 3.0"},
      {:hackney, "~> 1.20"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:postgrex, ">= 0.0.0"},
      {:tarams, "~> 1.0.0"},
      {:elasticsearch, "~> 1.0.0"}
    ]
  end
end
