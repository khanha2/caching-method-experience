require Logger

alias HugeSeller.Repository

alias HugeSeller.Schema.StoreDelivery

deliveries = Repository.list_cached_deliveries()

total_deliveries = length(deliveries)

delivery_map =
  deliveries
  |> Enum.sort_by(& &1.code)
  |> Enum.with_index()
  |> Enum.into(%{}, fn {delivery, index} -> {index, delivery} end)

Repository.list_cached_stores()
|> Enum.sort_by(& &1.code)
|> Enum.with_index()
|> Enum.each(fn {store, index} ->
  delivery = delivery_map[rem(index, total_deliveries)]

  %StoreDelivery{}
  |> StoreDelivery.changeset(%{store_code: store.code, delivery_code: delivery.code})
  |> HugeSeller.Repo.insert()
  |> case do
    {:ok, _store_delivery} ->
      Logger.info("Store delivery #{store.code},#{delivery.code} created")

    _error ->
      nil
  end
end)
