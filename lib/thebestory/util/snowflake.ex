defmodule TheBestory.Util.Snowflake do
  @moduledoc """
  This module is the interface for working with Snowflake IDs.
  """

  @doc """
  Generates a new Snowflake ID.
  """
  def next, do: Snowflake.next_id()

  @doc """
  Generates a new Snowflake ID.
  """
  def next! do
    {:ok, id} = Snowflake.next_id()
    id
  end
end
