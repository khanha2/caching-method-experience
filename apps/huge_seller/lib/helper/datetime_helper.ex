defmodule HugeSeller.DateTimeHelper do
  def to_datetime(%NaiveDateTime{} = value) do
    value
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.truncate(:second)
  end

  def utc_now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
