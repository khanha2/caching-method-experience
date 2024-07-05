defmodule HugeSeller.Repo.Migrations.CreateWarehouses do
  use Ecto.Migration

  def change do
    create table(:warehouses) do
      add(:code, :text)
      add(:name, :text)
    end

    create(unique_index(:warehouses, [:code]))
  end
end
