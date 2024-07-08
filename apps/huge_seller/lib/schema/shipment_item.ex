defmodule HugeSeller.Schema.ShipmentItem do
  @moduledoc """
  DB schema for storing shipment items
  """
  use HugeSeller, :schema

  schema "shipment_items" do
    field(:order_code, :string)
    field(:store_code, :string)
    field(:shipment_code, :string)
    field(:product_sku, :string)
    field(:quantity, :integer)

    belongs_to(:shipment, HugeSeller.Schema.Shipment)

    timestamps()
  end

  @fields [
    :order_code,
    :store_code,
    :shipment_code,
    :product_sku
  ]

  def changeset(shipment_item, params \\ %{}) do
    shipment_item
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
