defmodule HugeSeller.Schema.ShipmentStatus do
  def new, do: "new"

  def packed, do: "packed"

  def ready_to_ship, do: "ready_to_ship"

  def shipped, do: "shipped"

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
  DB schema for storing orders
  """
  use HugeSeller, :schema

  alias HugeSeller.Schema.ShipmentStatus
  alias HugeSeller.Schema.ShipmentType

  schema "shipments" do
    field(:code, :string)
    field(:order_code, :string)
    field(:store_code, :string)
    field(:type, :string, default: ShipmentType.main())
    field(:status, :string, default: ShipmentStatus.new())
    field(:created_at, :utc_datetime)

    # has_many(:items, HugeSeller.Schema.ShipmentItem)

    timestamps()
  end

  @fields [
    :code,
    :order_code,
    :store_code,
    :created_at
  ]

  def changeset(order, params \\ %{}) do
    order
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code)
  end
end
