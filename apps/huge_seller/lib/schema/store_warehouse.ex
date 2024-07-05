defmodule HugeSeller.Schema.StoreWarehouse do
  @moduledoc """
  DB schema for assigning a warehouse to a store
  """
  use HugeSeller, :schema

  schema "stores" do
    field(:store_code, :string)
    field(:warehouse_code, :string)
  end

  @fields [
    :store_code,
    :warehouse_code
  ]

  def changeset(store_warehouse, params \\ %{}) do
    store_warehouse
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(@fields)
  end
end
