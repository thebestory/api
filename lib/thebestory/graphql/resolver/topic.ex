defmodule TheBestory.GraphQL.Resolver.Topic do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.GraphQL.Resolver
  alias TheBestory.Repo.Schema.Topic

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id} = _args, _info) do
    case Repo.get(Topic, id) do
      nil   -> {:error, "Topic with Snowflake ID ##{id} not found."}
      topic -> {:ok, topic}
    end
  end

  def find(%{slug: slug} = _args, _info) do
    case Repo.get_by(Topic, slug: slug) do
      nil   -> {:error, "Topic with slug @#{slug} not found."}
      topic -> {:ok, topic}
    end
  end

  def find(_args, _info),
    do: {:error, "Snowflake ID or slug must be specified to find a topic."}

  # Process list

  def list(%{} = args, info),
    do: {:ok, list_process_listing(Topic, args, info) |> Repo.all}

  def list(query, %{} = args, info),
    do: list_process_listing(query, args, info)

  # Process list listing

  defp list_process_listing(query, %{after: id} = args, info) do
    case Resolver.Topic.find(%{id: id}, info) do
      {:ok, topic} ->
        query
        |> where([t], t.title >= ^topic.title)
        |> where([t], t.id < ^topic.id)
        |> list_proccess_query(args, info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp list_process_listing(query, %{before: id} = args, info) do
    case Resolver.Topic.find(%{id: id}, info) do
      {:ok, topic} ->
        query
        |> where([t], t.title <= ^topic.title)
        |> where([t], t.id > ^topic.id)
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
    |> order_by([t], asc: t.title, desc: t.id)
  end

  defp list_proccess_query(query, %{} = _args, _info) do
    query
    |> order_by([t], asc: t.title, desc: t.id)
  end

  # Process create

  def create(%{} = args, _info) do
    changeset = Topic.changeset(%Topic{}, args)

    case Repo.insert(changeset) do
      {:ok, topic} -> {:ok, topic}
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
    case Resolver.Topic.find(%{id: id}, info) do
      {:ok, topic} ->
        case Repo.update(Topic.changeset(topic, args)) do
          {:ok, topic} -> {:ok, topic}
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
end
