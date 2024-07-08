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
    field(:warehouse_code, :string)
    field(:package_code, :string)
    field(:type, :string)
    field(:status, :string)
    field(:created_at, :utc_datetime)

    has_many(:items, HugeSeller.Schema.ShipmentItem)

    timestamps()
  end

  @fields [
    :code,
    :order_code,
    :store_code,
    :warehouse_code,
    :created_at,
    :type,
    :status
  ]

  def changeset(order, params \\ %{}) do
    order
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code)
  end
end
