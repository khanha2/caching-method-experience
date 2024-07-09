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

  @default_fields [
    :id,
    :inserted_at,
    :updated_at
  ]

  @required_fields [
    :shipment_id,
    :shipment_code,
    :product_sku,
    :quantity
  ]

  def changeset(shipment_item, attrs) do
    shipment_item
    |> cast(attrs, __MODULE__.__schema__(:fields) -- @default_fields)
    |> validate_required(@required_fields)
  end
end
