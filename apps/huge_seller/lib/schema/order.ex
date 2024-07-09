defmodule HugeSeller.Schema.OrderStatus do
  def pending, do: "pending"

  def new, do: "new"

  def wh_processing, do: "wh_processing"

  def wh_completed, do: "wh_completed"

  def delivering, do: "delivering"

  def completed, do: "completed"

  def returning, do: "returning"

  def returned, do: "returned"
end

defmodule HugeSeller.Schema.Order do
  @moduledoc """
  DB schema for storing orders
  """
  use HugeSeller, :schema

  alias HugeSeller.Schema.OrderStatus

  schema "orders" do
    field(:code, :string)
    field(:status, :string, default: OrderStatus.new())
    field(:platform_status, :string)
    field(:created_at, :utc_datetime)

    field(:store_code, :string)

    has_many(:items, HugeSeller.Schema.OrderItem)
    has_many(:shipments, HugeSeller.Schema.Shipment)

    timestamps()
  end

  @default_fields [
    :id,
    :inserted_at,
    :updated_at
  ]

  @required_fields [
    :code
  ]

  def changeset(order, attrs) do
    order
    |> cast(attrs, __MODULE__.__schema__(:fields) -- @default_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
