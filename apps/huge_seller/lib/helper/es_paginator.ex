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
  def paginate(query, cluster, index, params \\ %{}) do
    with {:ok, data} <- HugeSeller.Parser.cast(params, @schema),
         search_query <- prepare_search_query(query, data),
         {:ok, count_response} <- Elasticsearch.post(cluster, "/#{index}/_doc/_count", query),
         {:ok, search_response} <-
           Elasticsearch.post(cluster, "/#{index}/_doc/_search", search_query) do
      %{"count" => total} = count_response
      %{"hits" => %{"hits" => hits}} = search_response
      pagination = %{total: total, page: data.page, size: data.size}
      {:ok, {entries, pagination}}
    end
  end

  defp prepare_search_query(query, data) do
    page = data.page || @default_page
    size = data.size || @default_size
    from = size * (page - 1)

    # Adjust the Elasticsearch query to include pagination
    Map.merge(query, %{"from" => from, "size" => size})
  end
end
