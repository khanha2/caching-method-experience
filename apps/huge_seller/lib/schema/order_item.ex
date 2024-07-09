defmodule HugeSeller.Schema.OrderItem do
  @moduledoc """
  DB schema for storing order items
  """
  use HugeSeller, :schema

  schema "order_items" do
    field(:product_sku, :string)
    field(:warehouse_code, :string)
    field(:package_code, :string)
    field(:quantity, :integer)

    belongs_to(:order, HugeSeller.Schema.Order)

    timestamps()
  end

  @default_fields [
    :id,
    :inserted_at,
    :updated_at
  ]

  @required_fields [
    :product_sku,
    :warehouse_code,
    :package_code,
    :quantity
  ]

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, __MODULE__.__schema__(:fields) -- @default_fields)
    |> validate_required(@required_fields)
  end
end
