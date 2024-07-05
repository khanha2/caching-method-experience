require Logger

alias HugeSeller.Repository

alias HugeSeller.Schema.StoreWarehouse

warehouses = Repository.list_cached_warehouses()

total_warehouses = length(warehouses)

warehouse_map =
  warehouses
  |> Enum.sort_by(& &1.code)
  |> Enum.with_index()
  |> Enum.into(%{}, fn {warehouse, index} -> {index, warehouse} end)

Repository.list_cached_stores()
|> Enum.sort_by(& &1.code)
|> Enum.with_index()
|> Enum.each(fn {store, index} ->
  warehouse = warehouse_map[rem(index, total_warehouses)]

  %StoreWarehouse{}
  |> StoreWarehouse.changeset(%{store_code: store.code, warehouse_code: warehouse.code})
  |> HugeSeller.Repo.insert()
  |> case do
    {:ok, _store_warehouse} ->
      Logger.info("Store warehouse #{store.code},#{warehouse.code} created")

    _error ->
      nil
  end
end)
