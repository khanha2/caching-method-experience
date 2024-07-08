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

  @fields [
    :code,
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
