defmodule HugeSeller.Usecase.UpdateOrderCache do
  @orders_index HugeSeller.ElasticClusterIndex.orders()

  @code_type [type: :string, length: [min: 1]]

  @schema %{
    code: [type: :string, required: true],
    status: @code_type,
    platform_status: @code_type
  }

  def perform(params) do
    with {:ok, %{code: code} = data} <- HugeSeller.Parser.cast(params, @schema),
         {:ok, query} <- build_query(data),
         {:ok, _result} <-
           Elasticsearch.post(
             HugeSeller.ElasticCluster,
             "/#{@orders_index}/_update/#{code}",
             query
           ) do
      :ok
    end
  end

  defp build_query(data) do
    data
    |> Map.drop([:code])
    |> Enum.filter(fn {_key, value} -> not is_nil(value) end)
    |> case do
      [] ->
        {:error, "no value to be updated"}

      query ->
        {:ok, %{"doc" => Enum.into(query, %{})}}
    end
  end
end
