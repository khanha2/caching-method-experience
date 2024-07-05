defmodule HugeSeller.Schema.Delivery do
  @moduledoc """
  DB schema for storing deliveries
  """
  use HugeSeller, :schema

  schema "deliveries" do
    field(:code, :string)
    field(:name, :string)
  end

  @fields [
    :code,
    :name
  ]

  def changeset(delivery, params \\ %{}) do
    delivery
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code)
  end
end
