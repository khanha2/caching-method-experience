defmodule HugeSeller.Schema.Warehouse do
  @moduledoc """
  DB schema for storing warehouses
  """
  use HugeSeller, :schema

  schema "warehouses" do
    field(:code, :string)
    field(:name, :string)
  end

  @fields [
    :code,
    :name
  ]

  def changeset(warehouse, params \\ %{}) do
    warehouse
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code)
  end
end
