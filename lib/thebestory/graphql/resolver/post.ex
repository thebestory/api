defmodule TheBestory.GraphQL.Resolver.Post do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.Ecto.Schema.Post

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id}, _info) when not is_nil(id) do
    case Repo.get(Post, id) do
      nil  -> {:error, "Post with Snowflake ID ##{id} not found."}
      post -> {:ok, post}
    end
  end

  def find(_opts, _info),
    do: {:error, "Snowflake ID must be specified to find a post."}

  # Process list

  def list(%{} = opts, info),
    do: {:ok, list_process_listing(Post, opts, info) |> Repo.all}

  def list(query, %{} = opts, info),
    do: list_process_listing(query, opts, info)

  # Process list listing

  defp list_process_listing(query, %{after: after_} = opts, info)
  when not is_nil(after_) do
    case Repo.get(Post, after_) do
      nil  -> {:error, "Post with Snowflake ID ##{after_} not found."}
      post -> list_process_listing_type(query, :after, post, opts, info)
    end
  end

  defp list_process_listing(query, %{before: before} = opts, info)
  when not is_nil(before) do
    case Repo.get(Post, before) do
      nil  -> {:error, "Post with Snowflake ID ##{before} not found."}
      post -> list_process_listing_type(query, :before, post, opts, info)
    end
  end

  defp list_process_listing(query, %{} = opts, info) do
    list_process_type(query, opts, info)
  end

  # Process list listing and type

  defp list_process_listing_type(query, :after, post, %{type: :latest} = opts, info) do
    query
    |> where([p], p.published_at <= ^post.published_at)
    |> where([p], p.id < ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, :after, post, %{type: :top} = opts, info) do
    query
    |> where([p], p.likes_count <= ^post.likes_count)
    |> where([p], p.replies_count <= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, :after, post, %{type: :hot} = opts, info) do
    query
    |> where([p], p.likes_count <= ^post.likes_count)
    |> where([p], p.replies_count <= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :latest} = opts, info) do
    query
    |> where([p], p.published_at >= ^post.published_at)
    |> where([p], p.id > ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :top} = opts, info) do
    query
    |> where([p], p.likes_count >= ^post.likes_count)
    |> where([p], p.replies_count >= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :hot} = opts, info) do
    query
    |> where([p], p.likes_count >= ^post.likes_count)
    |> where([p], p.replies_count >= ^post.replies_count)
    |> where([p], p.id > ^post.id)
    |> list_process_type(opts, info)
  end

  defp list_process_listing_type(query, _, _post, %{type: :random} = opts, info) do
    query
    |> list_process_type(opts, info)
  end

  # Process list type

  defp list_process_type(query, %{type: :latest} = opts, info) do
    query
    |> order_by([p], desc: p.published_at, desc: p.id)
    |> list_process_query(opts, info)
  end

  defp list_process_type(query, %{type: :top} = opts, info) do
    query
    |> order_by([p], desc: p.likes_count, desc: p.replies_count, desc: p.id)
    |> list_process_query(opts, info)
  end

  defp list_process_type(query, %{type: :hot} = opts, info) do
    query
    |> order_by([p], desc: p.likes_count, desc: p.replies_count, desc: p.id)
    |> list_process_query(opts, info)
  end

  defp list_process_type(query, %{type: :random} = opts, info) do
    query
    |> order_by(fragment("random()"))
    |> list_process_query(opts, info)
  end

  # Process list query

  defp list_process_query(query, %{limit: limit_} = opts, info) do
    query
    |> list_process_authors(opts, info)
    |> list_process_topics(opts, info)
    |> where([p], p.is_published == ^true)
    |> where([p], p.is_deleted == ^false)
    |> limit(^min(@listing_max_limit, max(@listing_min_limit, limit_)))
  end

  # Process list query

  defp list_process_authors(query, %{authors: authors} = _opts, _info) do
    case authors do
      []      -> query
      authors -> query
                 |> where([p], p.author_id in ^(authors |> Enum.uniq))
    end
  end

  defp list_process_authors(query, %{} = _opts, _info),
    do: query

  defp list_process_topics(query, %{topics: topics} = _opts, _info) do
    case topics do
      []     -> query
      topics -> query
                |> join(:inner, [p], t in assoc(p, :topics))
                |> where([p, t], t.id in ^(topics |> Enum.uniq))
    end
  end

  defp list_process_topics(query, %{} = _opts, _info),
    do: query
end
