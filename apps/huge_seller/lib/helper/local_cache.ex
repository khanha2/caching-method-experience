defmodule HugeSeller.LocalCache do
  @moduledoc false
  @cache_name :local_cache

  # default ttl is 5 minutes
  @default_ttl_seconds 300

  def create_connection_spec do
    {Cachex, name: :local_cache}
  end

  @doc """
  Get value from cache, if not found, run function and update to cache
  """
  def get_or_set(key, fun, opts \\ []) when is_function(fun) do
    case get(key) do
      nil ->
        value = fun.()
        set(key, value, opts)
        value

      value ->
        value
    end
  end

  @doc """
  Get a value from the cache

  If the key exists, return the value, otherwise return nil
  """
  @spec get(String.t()) :: nil | any
  def get(key) do
    case Cachex.get(@cache_name, key) do
      {:ok, value} when not is_nil(value) -> value
      _ -> nil
    end
  end

  @doc """
  Set key value in cache, default ttl is 5 minutes
  """
  def set(key, value, opts \\ []) do
    ttl = opts[:ttl] || @default_ttl_seconds

    case Cachex.put(@cache_name, key, value, ttl: :timer.seconds(ttl)) do
      {:ok, true} -> :ok
      _ -> :error
    end
  end
end
