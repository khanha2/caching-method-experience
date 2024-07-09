defmodule HugeSeller.EsPaginator do
  @moduledoc """
  Build and query data with pagination
  """
  @default_page 1

  @default_size 20

  @schema %{
    page: [
      type: :integer,
      default: @default_page,
      validate: {:number, greater_than_or_equal_to: 1}
    ],
    size: [
      type: :integer,
      default: @default_size,
      validate: {:number, [greater_than_or_equal_to: 1, less_than_or_equal_to: 100]}
    ]
  }

  @doc """
  Return query result with pagination
  """
  def paginate(query, cluster, index, params \\ %{}) do
    with {:ok, data} <- HugeSeller.Parser.cast(params, @schema) do
      page = data.page || @default_page
      size = data.size || @default_size
      from = size * (page - 1)

      # Adjust the Elasticsearch query to include pagination
      query = Map.put(query, "from", from)
      query = Map.put(query, "size", size)

      # Execute the search query
      IO.inspect(Elasticsearch.post(cluster, "/#{index}/_doc/_search", query))

      # total = repo.aggregate(query, :count, :id)

      # pagination = %{
      #   page: page,
      #   size: size,
      #   total: total
      # }

      # entries = from(query, limit: ^size, offset: ^offset) |> repo.all()
    end
  end
end
