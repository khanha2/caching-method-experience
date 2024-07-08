require Logger

alias HugeSeller.Repo
alias HugeSeller.Schema.Delivery

Enum.each(1..1, fn delivery_id ->
  %Delivery{}
  |> Delivery.changeset(%{code: "delivery_#{delivery_id}", name: "Delivery #{delivery_id}"})
  |> Repo.insert()
  |> case do
    {:ok, delivery} ->
      Logger.info("Delivery #{delivery.code} created")

    _error ->
      nil
  end
end)
