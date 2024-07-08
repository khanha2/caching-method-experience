defmodule HugeSeller.Schema.Order do
  @moduledoc """
  DB schema for storing orders
  """
  use HugeSeller, :schema

  schema "orders" do
    field(:code, :string)
    field(:created_at, :utc_datetime)

    field(:store_code, :string)

    has_many(:items, HugeSeller.Schema.OrderItem)

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