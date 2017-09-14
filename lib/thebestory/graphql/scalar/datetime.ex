defmodule TheBestory.GraphQL.Scalar.DateTime do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc """
  The `DateTime` scalar type represents a date and time in the UTC
  timezone. The DateTime appears in a JSON response as an ISO8601 formatted
  string, including UTC timezone ("Z"). The parsed date and time string will
  be converted to UTC and any UTC offset other than 0 will be rejected.
  """
  scalar :datetime, name: "DateTime" do
    parse &parse_datetime/1
    serialize &serialize_datetime/1
  end

  defp parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case Timex.parse(value, "{ISO:Extended:Z}") do
      {:ok, datetime} -> {:ok, datetime}
      _               -> :error
    end
  end

  defp parse_datetime(_) do
    :error
  end

  defp serialize_datetime(value) do
    case Timex.format(value, "{ISO:Extended:Z}") do
      {:ok, datetime} -> datetime
      _               -> :error
    end
  end
end
