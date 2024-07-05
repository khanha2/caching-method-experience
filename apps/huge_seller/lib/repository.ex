defmodule HugeSeller.Repository do
  alias HugeSeller.LocalCache
  alias HugeSeller.Repo

  alias HugeSeller.Schema.Store
  alias HugeSeller.Schema.Warehouse

  @doc """
  List cached stores
  """
  @spec list_cached_stores() :: [Store.t()]
  def list_cached_stores do
    LocalCache.get_or_set("stores", fn ->
      Repo.all(Store)
    end)
  end

  @doc """
  List cached warehouses
  """
  @spec list_cached_warehouses() :: [Warehouse.t()]
  def list_cached_warehouses do
    LocalCache.get_or_set("warehouses", fn ->
      Repo.all(Warehouse)
    end)
  end
end
