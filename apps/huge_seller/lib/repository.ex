defmodule HugeSeller.Repository do
  alias HugeSeller.ElasticCluster

  @doc """
  Count orders by ES
  """
  @spec count_es_orders(query :: map(), index :: String.t()) :: {:ok, integer()} | {:error, any()}
  def count_es_orders(query, index) do
    with {:ok, count_response} <-
           Elasticsearch.post(ElasticCluster, "/#{index}/_doc/_count", query) do
      {:ok, count_response["count"]}
    end
  end

  @doc """
  Count orders
  """
  @spec count_orders(query :: Ecto.Query.t()) :: {:ok, integer()} | {:error, any()}
  def count_orders(query) do
    HugeSeller.Repo.aggregate(query, :count, :id)
  end
end
