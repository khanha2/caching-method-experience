defmodule HugeSeller.Schema.OrderItem do
  @moduledoc """
  DB schema for storing order items
  """
  use HugeSeller, :schema

  schema "order_items" do
    field(:product_sku, :string)
    field(:warehouse_code, :string)
    field(:package_code, :string)

    belongs_to(:order, HugeSeller.Schema.Order)

    timestamps()
  end

  @fields [
    :product_sku,
    :warehouse_code,
    :delivery_code,
    :package_code,
    :order_id
  ]

  def changeset(order_item, params \\ %{}) do
    order_item
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
