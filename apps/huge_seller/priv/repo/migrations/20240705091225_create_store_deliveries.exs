defmodule HugeSeller.Repo.Migrations.CreateStoreDeliveries do
  use Ecto.Migration

  def change do
    create table(:store_deliveries) do
      add(:store_code, :text)
      add(:delivery_code, :text)
    end

    create(unique_index(:store_deliveries, [:store_code, :delivery_code]))
    create(index(:store_deliveries, [:store_code]))
    create(index(:store_deliveries, [:delivery_code]))
  end
end
