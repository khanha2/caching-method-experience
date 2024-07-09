defmodule HugeSeller.Parser do
  @doc """
  Cast and validate params with given schema.
  """
  @spec cast(data :: map(), schema :: map()) :: {:ok, map()} | {:error, :invalid, errors :: map()}
  def cast(params, schema) do
    case Tarams.cast(params, schema) do
      {:ok, data} ->
        {:ok, data}

      {:error, errors} ->
        {:error, :invalid, errors}
    end
  end

  @doc """
  Parse string to string array
  """
  @spec to_string_array(value :: String.t()) :: {:ok, list(String.t()) | nil}
  def to_string_array(value, separator \\ ",") do
    if is_nil(value) do
      {:ok, nil}
    else
      values = String.split(value, separator, trim: true)
      {:ok, values}
    end
  end
end
