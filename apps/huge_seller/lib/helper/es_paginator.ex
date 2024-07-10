defmodule HugeSeller.EsPaginator do
  @moduledoc """
  Build and query data with pagination
  """

  # Determine the scroll timeout for pagination
  # 1 minute
  @scroll_timeout "1m"

  @default_size 20

  @schema %{
    scroll_id: :string,
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
         search_query <- prepare_search_query(data),
         {:ok, response} <- query_entries(search_query, cluster) do
      entries =
        response
        |> Map.get("hits", %{})
        |> Map.get("hits", [])

      next_scroll_id = Map.get(response, "_scroll_id")

      {:ok, {entries, next_scroll_id}}
    end
  end

  defp prepare_search_query(query, data) do
    case data[:scroll_id] do
      nil ->
        Map.put(query, "size", data[:size] || @default_size)

      _scroll_id ->
        data
    end
  end

  defp query_entries(%{scroll_id: scroll_id}, cluster) do
    Elasticsearch.post(cluster, "/_search/scroll", %{
      "scroll" => @scroll_timeout,
      "scroll_id" => scroll_id
    })
  end

  defp query_entries(query, cluster) do
    Elasticsearch.post(cluster, "/#{index}/_doc/_search?scroll=#{@scroll_timeout}", query)
  end
end
