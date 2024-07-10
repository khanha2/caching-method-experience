defmodule HugeSeller.Paginator do
  @moduledoc """
  Build and query data with pagination
  """
  import Ecto.Query, only: [from: 2]

  @default_page 1
  @default_size 20

  @schema %{
    page: [
      type: :integer,
      default: @default_page,
      number: [greater_than_or_equal_to: 1]
    ],
    size: [
      type: :integer,
      default: @default_size,
      number: [greater_than_or_equal_to: 1, less_than_or_equal_to: 100]
    ]
  }

  @doc """
  Return query result with pagination
  """
  @spec paginate(query :: Ecto.Query.t(), repo :: Ecto.Repo.t(), params :: map) ::
          {:ok, list(struct())} | {:error, any()}
  def paginate(query, repo, params \\ %{}) do
    with {:ok, data} <- HugeSeller.Parser.cast(params, @schema) do
      page = data.page || @default_page
      size = data.size || @default_size
      offset = size * (page - 1)

      pagination = %{
        page: page,
        size: size
      }

      entries = from(query, limit: ^size, offset: ^offset) |> repo.all()

      {:ok, entries}
    end
  end
end
