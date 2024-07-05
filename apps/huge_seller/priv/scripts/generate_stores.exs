require Logger

alias HugeSeller.Repo
alias HugeSeller.Schema.Store

Enum.map(1..1000, fn store_id ->
  %Store{}
  |> Store.changeset(%{code: "store_#{store_id}", name: "Store #{store_id}"})
  |> Repo.insert()
  |> case do
    {:ok, store} ->
      Logger.info("Store #{store.code} created")

    _error ->
      nil
  end
end)
