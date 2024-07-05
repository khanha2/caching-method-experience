defmodule HugeSeller.Schema.StoreDelivery do
  @moduledoc """
  DB schema for assigning a delivery to a store
  """
  use HugeSeller, :schema

  schema "store_deliveries" do
    field(:store_code, :string)
    field(:delivery_code, :string)
  end

  @fields [
    :store_code,
    :delivery_code
  ]

  def changeset(store_delivery, params \\ %{}) do
    store_delivery
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(@fields)
  end
end
