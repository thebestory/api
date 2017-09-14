defmodule TheBestory.GraphQL.Resolver.Topic do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.Ecto.Schema.Topic

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id}, _info) do
    case Repo.get(Topic, id) do
      nil   -> {:error, "Topic with Snowflake ID ##{id} not found."}
      topic -> {:ok, topic}
    end
  end

  def find(%{slug: slug}, _info) do
    case Repo.get_by(Topic, slug: slug) do
      nil   -> {:error, "Topic with slug @#{slug} not found."}
      topic -> {:ok, topic}
    end
  end

  def find(_opts, _info),
    do: {:error, "Snowflake ID or slug must be specified to find a topic."}

  # Process list

  def list(%{} = opts, info),
    do: {:ok, list_process_listing(Topic, opts, info) |> Repo.all}

  def list(query, %{} = opts, info),
    do: list_process_listing(query, opts, info)

  # Process list listing

  defp list_process_listing(query, %{after: after_} = opts, info)
  when not is_nil(after_) do
    case Repo.get(Topic, after_) do
      nil   -> {:error, "Topic with Snowflake ID ##{after_} not found."}
      topic -> query
               |> where([t], t.title >= ^topic.title)
               |> where([t], t.id < ^topic.id)
               |> list_proccess_query(opts, info)
    end
  end

  defp list_process_listing(query, %{before: before} = opts, info)
  when not is_nil(before) do
    case Repo.get(Topic, before) do
      nil   -> {:error, "Topic with Snowflake ID ##{before} not found."}
      topic -> query
               |> where([t], t.title <= ^topic.title)
               |> where([t], t.id > ^topic.id)
               |> list_proccess_query(opts, info)
    end
  end

  defp list_process_listing(query, %{} = opts, info) do
    list_proccess_query(query, opts, info)
  end

  # Process list query

  defp list_proccess_query(query, %{limit: limit_} = _opts, _info) do
    query
    |> order_by([t], asc: t.title, desc: t.id)
    |> limit(^min(@listing_max_limit, max(@listing_min_limit, limit_)))
  end
end
