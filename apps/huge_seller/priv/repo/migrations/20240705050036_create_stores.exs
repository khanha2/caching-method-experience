defmodule HugeSeller.Repo.Migrations.CreateStores do
  use Ecto.Migration

  def change do
    create table(:stores) do
      add(:code, :text)
      add(:name, :text)
    end

    create(unique_index(:stores, [:code]))
  end
end
