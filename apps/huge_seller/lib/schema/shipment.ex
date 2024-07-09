defmodule HugeSeller.Schema.ShipmentStatus do
  def new, do: "new"

  def packed, do: "packed"

  def ready_to_ship, do: "ready_to_ship"

  def shipped, do: "shipped"

  def cancelled, do: "cancelled"

  def enum do
    [new(), packed(), ready_to_ship(), shipped()]
  end
end

defmodule HugeSeller.Schema.ShipmentType do
  def main, do: "main"

  def refulfilling, do: "refulfilling"

  def compensation, do: "compensation"

  def enum do
    [main(), refulfilling(), compensation()]
  end
end

defmodule HugeSeller.Schema.Shipment do
  @moduledoc """
  DB schema for storing shipments
  """
  use HugeSeller, :schema

  schema "shipments" do
    field(:code, :string)
    field(:order_code, :string)
    field(:store_code, :string)
    field(:warehouse_platform_code, :string)
    field(:warehouse_shipment_code, :string)
    field(:warehouse_code, :string)
    field(:delivery_platform_code, :string)
    field(:tracking_code, :string)
    field(:package_code, :string)
    field(:type, :string)
    field(:status, :string)
    field(:warehouse_status, :string)
    field(:delivery_status, :string)
    field(:created_at, :utc_datetime)

    belongs_to(:order, HugeSeller.Schema.Order)
    has_many(:items, HugeSeller.Schema.ShipmentItem)

    timestamps()
  end

  @default_fields [
    :id,
    :inserted_at,
    :updated_at
  ]

  @required_fields [
    :code,
    :order_code,
    :store_code,
    :warehouse_code,
    :created_at,
    :type,
    :status
  ]

  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, __MODULE__.__schema__(:fields) -- @default_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
