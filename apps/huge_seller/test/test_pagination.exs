alias HugeSeller.ElasticCluster
alias HugeSeller.ElasticClusterIndex
alias HugeSeller.Repo

alias HugeSeller.EsPaginator
alias HugeSeller.Paginator

alias HugeSeller.Usecase.BuildOrderEsQuery
alias HugeSeller.Usecase.BuildOrderQuery

orders_index = ElasticClusterIndex.orders()

IO.inspect("Retriving orders with platform status is pl_new")

params = %{
  page: 1,
  size: 100,
  platform_status: "pl_new"
}

{:ok, es_query} = BuildOrderEsQuery.perform(params)

{es_first_time, {:ok, {_entries, next_scroll_id}}} =
  :timer.tc(fn -> EsPaginator.paginate(es_query, ElasticCluster, orders_index, params) end)

IO.inspect("ES: retrive first page with execution time is #{es_first_time / 1_000} ms")

{es_total_time, _} =
  :timer.tc(fn ->
    Enum.reduce(1..9, next_scroll_id, fn _number, acc ->
      params = Map.put(params, :scroll_id, acc)

      {:ok, {_entries, next_scroll_id}} =
        EsPaginator.paginate(es_query, ElasticCluster, orders_index, params)

      next_scroll_id
    end)
  end)

es_total_time = es_total_time + es_first_time

IO.inspect("ES: retrive 10 pages with execution time is #{es_total_time / 1_000} ms")

{:ok, pg_query} = BuildOrderQuery.perform(params)

{pg_first_time, {:ok, _entries}} =
  :timer.tc(fn -> Paginator.paginate(pg_query, Repo, params) end)

IO.inspect("PG: retrive first page with execution time is #{pg_first_time / 1_000} ms")

{pg_total_time, _} =
  :timer.tc(fn ->
    params = Map.put(params, :page, 10)

    Paginator.paginate(pg_query, Repo, params)
  end)

IO.inspect("PG: retrive 10 pages with execution time is #{pg_total_time / 1_000} ms")
