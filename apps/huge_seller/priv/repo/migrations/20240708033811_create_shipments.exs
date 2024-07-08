defmodule HugeSeller.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add(:code, :text)
      add(:order_code, :text)
      add(:store_code, :text)
      add(:type, :text)
      add(:status, :text)
      add(:created_at, :naive_datetime)

      timestamps(default: fragment("NOW()"))
    end

    create(unique_index(:shipments, [:code]))
    create(index(:shipments, [:order_code]))
    create(index(:shipments, [:store_code]))
    create(index(:shipments, [:type]))
    create(index(:shipments, [:status]))
    create(index(:shipments, [:created_at]))
    create(index(:shipments, [:updated_at]))
  end
end
