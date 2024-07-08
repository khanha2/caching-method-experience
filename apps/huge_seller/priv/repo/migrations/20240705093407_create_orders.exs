defmodule HugeSeller.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add(:code, :text)
      add(:store_code, :text)
      add(:created_at, :naive_datetime)

      timestamps(default: fragment("NOW()"))
    end

    create(unique_index(:orders, [:code]))
    create(index(:orders, [:store_code]))
    create(index(:orders, [:created_at]))
    create(index(:orders, [:updated_at]))
  end
end