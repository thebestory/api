defmodule TheBestory.GraphQL.Resolver.User do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.GraphQL.Resolver
  alias TheBestory.Repo.Schema.User

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id} = _args, _info) do
    case Repo.get(User, id) do
      nil  -> {:error, "User with Snowflake ID ##{id} not found."}
      user -> {:ok, user}
    end
  end

  def find(%{username: username} = _args, _info) do
    case Repo.get_by(User, username: username) do
      nil  -> {:error, "User with username @#{username} not found."}
      user -> {:ok, user}
    end
  end

  def find(_args, _info),
    do: {:error, "Snowflake ID or username must be specified to find a user."}

  # Process list

  def list(%{} = args, info),
    do: {:ok, list_process_listing(User, args, info) |> Repo.all}

  def list(query, %{} = args, info),
    do: list_process_listing(query, args, info)

  # Process list listing

  defp list_process_listing(query, %{after: id} = args, info) do
    case Resolver.User.find(%{id: id}, info) do
      {:ok, user} ->
        query
        |> where([u], u.registered_at <= ^user.registered_at)
        |> where([u], u.id < ^user.id)
        |> list_proccess_query(args, info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp list_process_listing(query, %{before: id} = args, info) do
    case Resolver.User.find(%{id: id}, info) do
      {:ok, user} ->
        query
        |> where([u], u.registered_at >= ^user.registered_at)
        |> where([u], u.id > ^user.id)
        |> list_proccess_query(args, info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp list_process_listing(query, %{} = args, info),
    do: list_proccess_query(query, args, info)

  # Process list query

  defp list_proccess_query(query, %{limit: limit_} = _args, _info) do
    query
    |> limit(^min(@listing_max_limit, max(@listing_min_limit, limit_)))
    |> order_by([u], desc: u.registered_at, desc: u.id)
  end

  defp list_proccess_query(query, %{} = _args, _info) do
    query
    |> order_by([u], desc: u.registered_at, desc: u.id)
  end

  # Process signup

  def create(%{} = args, _info) do
    changeset = User.changeset(%User{}, args)

    case Repo.insert(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {
        :error,
        %{
          message: "Validation error",
          details: traverse_errors(changeset, fn {msg, args} ->
            Enum.reduce(args, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)
        }
      }
    end
  end

  # Process update

  def update(%{id: id} = args, info) do
    case Resolver.User.find(%{id: id}, info) do
      {:ok, user} ->
        case Repo.update(User.changeset(user, args)) do
          {:ok, user} -> {:ok, user}
          {:error, changeset} -> {
            :error,
            %{
              message: "Validation error",
              details: traverse_errors(changeset, fn {msg, args} ->
                Enum.reduce(args, msg, fn {key, value}, acc ->
                  String.replace(acc, "%{#{key}}", to_string(value))
                end)
              end)
            }
          }
        end
      {:error, message} ->
        {:error, message}
    end
  end

  def update(%{} = args, info) do
    case info do
      %{context: %{authorization: %{user: %{id: id}}}} ->
        Resolver.User.update(Map.put(args, :id, id), info)
      _ ->
        {:error, "Snowflake ID must be specified to update a user."}
    end
  end
end
