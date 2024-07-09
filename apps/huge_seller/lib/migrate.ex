defmodule HugeSeller.Tasks do
  require Logger

  @app :huge_seller

  @es_migration_path "priv/elasticsearch"

  def migrate_es do
    Application.load(@app)

    with {:ok, file_names} <- File.ls(@es_migration_path) do
      Enum.each(file_names, &migrate_es_index(&1))
    end
  end

  defp migrate_es_index(file_name) do
    index = Path.basename(file_name, ".json")
    Logger.warning("Migrating #{index}")

    with {:ok, content} <- File.read("#{@es_migration_path}/#{file_name}"),
         {:ok, data} <- Jason.decode(content),
         {:ok, _data} <- Elasticsearch.put(HugeSeller.ElasticCluster, "/#{index}", data) do
      :ok
    else
      {:error, reason} ->
        Logger.error("Migrating #{index} failed #{inspect(reason)}")
    end
  end
end
