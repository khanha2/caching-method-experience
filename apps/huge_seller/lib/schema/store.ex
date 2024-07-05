defmodule HugeSeller.Schema.Store do
  @moduledoc """
  DB schema for the store
  """
  use HugeSeller, :schema

  schema "stores" do
    field(:code, :string)
    field(:name, :string)
  end

  @fields [
    :code,
    :name
  ]

  def changeset(store, params \\ %{}) do
    store
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:code)
  end
end
