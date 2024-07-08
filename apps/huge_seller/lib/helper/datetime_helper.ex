defmodule HugeSeller.DateTimeHelper do
  def to_datetime(%NaiveDateTime{} = value) do
    value
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.truncate(:second)
  end
end
