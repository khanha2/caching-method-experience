defmodule HugeSeller do
  @doc """
  Determines a module is a schema
  """
  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
    end
  end

  @doc """
  When used, dispatch to the appropriate schema/usecase/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
