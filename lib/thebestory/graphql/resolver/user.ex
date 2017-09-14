defmodule TheBestory.GraphQL.Resolver.User do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.Ecto.Schema.User

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id} = _opts, _info) do
    case Repo.get(User, id) do
      nil  -> {:error, "User with Snowflake ID ##{id} not found."}
      user -> {:ok, user}
    end
  end

  def find(%{username: username} = _opts, _info) do
    case Repo.get_by(User, username: username) do
      nil  -> {:error, "User with username @#{username} not found."}
      user -> {:ok, user}
    end
  end

  def find(_opts, _info),
    do: {:error, "Snowflake ID or username must be specified to find a user."}

  # Process list

  def list(%{} = opts, info),
    do: {:ok, list_process_listing(User, opts, info) |> Repo.all}

  def list(query, %{} = opts, info),
    do: list_process_listing(query, opts, info)

  # Process list listing

  defp list_process_listing(query, %{after: after_} = opts, info)
  when not is_nil(after_) do
    case Repo.get(User, after_) do
      nil  -> {:error, "User with Snowflake ID ##{after_} not found."}
      user -> query
              |> where([u], u.registered_at <= ^user.registered_at)
              |> where([u], u.id < ^user.id)
              |> list_proccess_query(opts, info)
    end
  end

  defp list_process_listing(query, %{before: before} = opts, info)
  when not is_nil(before) do
    case Repo.get(User, before) do
      nil  -> {:error, "User with Snowflake ID ##{before} not found."}
      user -> query
              |> where([u], u.registered_at >= ^user.registered_at)
              |> where([u], u.id > ^user.id)
              |> list_proccess_query(opts, info)
    end
  end

  defp list_process_listing(query, %{} = opts, info) do
    list_proccess_query(query, opts, info)
  end

  # Process list query

  defp list_proccess_query(query, %{limit: limit_} = _opts, _info) do
    query
    |> order_by([u], desc: u.registered_at, desc: u.id)
    |> limit(^min(@listing_max_limit, max(@listing_min_limit, limit_)))
  end
end
