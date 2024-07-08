require Logger

alias HugeSeller.Repo
alias HugeSeller.Schema.Warehouse

Enum.each(1..2, fn warehouse_id ->
  %Warehouse{}
  |> Warehouse.changeset(%{code: "warehouse_#{warehouse_id}", name: "Warehouse #{warehouse_id}"})
  |> Repo.insert()
  |> case do
    {:ok, warehouse} ->
      Logger.info("Warehouse #{warehouse.code} created")

    _error ->
      nil
  end
end)
