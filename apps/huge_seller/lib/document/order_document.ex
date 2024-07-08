defimpl Elasticsearch.Document, for: HugeSeller.Schema.Order do
  def id(order), do: order.code

  def routing(_), do: false

  def encode(order) do
    %{
      id: order.code,
      code: order.code,
      store_code: order.store_code,
      created_at: order.created_at,
      updated_at: HugeSeller.DateTimeHelper.to_datetime(order.updated_at)
    }
  end
end
