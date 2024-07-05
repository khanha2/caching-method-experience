defmodule HugeSeller.Repo.Migrations.CreateStoreWarehouses do
  use Ecto.Migration

  def change do
    create table(:store_warehouses) do
      add(:store_code, :text)
      add(:warehouse_code, :text)
    end

    create(unique_index(:store_warehouses, [:store_code, :warehouse_code]))
    create(index(:store_warehouses, [:store_code]))
    create(index(:store_warehouses, [:warehouse_code]))
  end
end
