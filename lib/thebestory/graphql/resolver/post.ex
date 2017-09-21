defmodule TheBestory.GraphQL.Resolver.Post do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.GraphQL.Resolver
  alias TheBestory.Repo.Schema.{Like, Post, PostTopic, Topic, User}

  @listing_min_limit 1
  @listing_max_limit 1000
  @listing_default_limit 100

  # Process find

  def find(%{id: id} = _args, info) when not is_nil(id) do
    case Repo.get(Post, id) do
      nil  -> {:error, "Post with Snowflake ID ##{id} not found."}
      post ->
        case info do
          %{context: %{authorization: %{user: %{id: id}}}} ->
            query = Like
                    |> where([l], l.user_id == ^id)
                    |> where([l], l.post_id == ^post.id)
                    |> where([l], l.is_unliked == false)
                    |> order_by([l], desc: l.liked_at)

            case Repo.all(query) do
              [_like | _] ->
                {:ok, Map.put(post, :is_liked, true)}
              _ ->
                {:ok, Map.put(post, :is_liked, false)}
            end
          _ ->
            {:ok, Map.put(post, :is_liked, false)}
        end
    end
  end

  def find(_args, _info),
    do: {:error, "Snowflake ID must be specified to find a post."}

  # Process list

  def list(%{} = args, info) do 
    posts = list_process_listing(Post, args, info) |> Repo.all

    {:ok, Enum.map(posts, fn post ->
      case info do
        %{context: %{authorization: %{user: %{id: id}}}} ->
          query = Like
                  |> where([l], l.user_id == ^id)
                  |> where([l], l.post_id == ^post.id)
                  |> where([l], l.is_unliked == false)
                  |> order_by([l], desc: l.liked_at)

          case Repo.all(query) do
            [_like | _] ->
              Map.put(post, :is_liked, true)
            _ ->
              Map.put(post, :is_liked, false)
          end
        _ ->
          Map.put(post, :is_liked, false)
      end
    end)}
  end

  def list(query, %{} = args, info),
    do: list_process_listing(query, args, info)

  # Process list listing

  defp list_process_listing(query, %{after: id} = args, info) do
    case Resolver.Post.find(%{id: id}, info) do
      {:ok, post} ->
        list_process_listing_type(query, :after, post, args, info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp list_process_listing(query, %{before: id} = args, info) do
    case Resolver.Post.find(%{id: id}, info) do
      {:ok, post} ->
        list_process_listing_type(query, :before, post, args, info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp list_process_listing(query, %{} = args, info),
    do: list_process_type(query, args, info)

  # Process list listing and type

  defp list_process_listing_type(query, :after, post, %{type: :latest} = args, info) do
    query
    |> where([p], p.published_at <= ^post.published_at)
    |> where([p], p.id < ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, :after, post, %{type: :top} = args, info) do
    query
    |> where([p], p.likes_count <= ^post.likes_count)
    |> where([p], p.replies_count <= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, :after, post, %{type: :hot} = args, info) do
    query
    |> where([p], p.likes_count <= ^post.likes_count)
    |> where([p], p.replies_count <= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :latest} = args, info) do
    query
    |> where([p], p.published_at >= ^post.published_at)
    |> where([p], p.id > ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :top} = args, info) do
    query
    |> where([p], p.likes_count >= ^post.likes_count)
    |> where([p], p.replies_count >= ^post.replies_count)
    |> where([p], p.id < ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, :before, post, %{type: :hot} = args, info) do
    query
    |> where([p], p.likes_count >= ^post.likes_count)
    |> where([p], p.replies_count >= ^post.replies_count)
    |> where([p], p.id > ^post.id)
    |> list_process_type(args, info)
  end

  defp list_process_listing_type(query, _, _post, %{type: :random} = args, info) do
    query
    |> list_process_type(args, info)
  end

  # Process list type

  defp list_process_type(query, %{type: :latest} = args, info) do
    query
    |> order_by([p], desc: p.published_at, desc: p.id)
    |> list_process_query(args, info)
  end

  defp list_process_type(query, %{type: :top} = args, info) do
    query
    |> order_by([p], desc: p.likes_count, desc: p.replies_count, desc: p.id)
    |> list_process_query(args, info)
  end

  defp list_process_type(query, %{type: :hot} = args, info) do
    query
    |> order_by([p], desc: p.likes_count, desc: p.replies_count, desc: p.id)
    |> list_process_query(args, info)
  end

  defp list_process_type(query, %{type: :random} = args, info) do
    query
    |> order_by(fragment("random()"))
    |> list_process_query(args, info)
  end

  # Process list query

  defp list_process_query(query, %{limit: limit_} = args, info) do
    query
    |> list_process_authors(args, info)
    |> list_process_parents(args, info)
    |> list_process_topics(args, info)
    |> where([p], p.is_published == true)
    |> where([p], p.is_deleted == false)
    |> limit(^min(@listing_max_limit, max(@listing_min_limit, limit_)))
  end

  # Process list query

  defp list_process_authors(query, %{authors: authors} = _args, _info) do
    case authors do
      []      -> query
      authors -> query
                 |> where([p], p.author_id in ^(authors |> Enum.uniq))
    end
  end

  defp list_process_authors(query, %{} = _args, _info),
    do: query

  defp list_process_parents(query, %{parents: parents} = _args, _info) do
    case parents do
      []      -> query
      parents -> query
                 |> where([p], p.parent_id in ^(parents |> Enum.uniq))
                 |> where([p], p.parent_id != p.id)
    end
  end

  defp list_process_parents(query, %{} = _args, _info),
    do: query

  defp list_process_topics(query, %{topics: topics} = _args, _info) do
    case topics do
      []     -> query
      topics -> query
                |> join(:inner, [p], pt in PostTopic)
                |> where([p, pt], pt.topic_id in ^(topics |> Enum.uniq))
                |> where([p, pt], pt.post_id == p.id)
                |> where([p, pt], pt.is_deleted == false)
    end
  end

  defp list_process_topics(query, %{} = _args, _info),
    do: query

  # Process create

  def create(%{} = args, info) do
    create_process_author(args, info)
  end

  defp create_process_author(%{author: author} = args, info) do
    case Resolver.User.find(%{id: author}, info) do
      {:ok, author} ->
        create_process_parent(Map.put(args, :author, author.id), info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp create_process_author(%{} = args, info) do
    case info do
      %{context: %{authorization: %{user: %{id: id}}}} ->
        create_process_author(Map.put(args, :author, id), info)
      _ ->
        {:error, "Author's Snowflake ID must be specified."}
    end
  end

  defp create_process_parent(%{parent: parent} = args, info) do
    case Resolver.Post.find(%{id: parent}, info) do
      {:ok, parent} ->
        create_process_query(
          args |> Map.put(:root, parent.root_id)
               |> Map.put(:parent, parent.id),
          info)
      {:error, message} ->
        {:error, message}
    end
  end

  defp create_process_parent(%{} = args, info) do
    create_process_query(
      args |> Map.put(:root, nil)
           |> Map.put(:parent, nil),
      info)
  end

  defp create_process_query(%{author: author, 
                              root: root,
                              parent: parent} = args, info) do
    changeset = Post.changeset(
      %Post{},
      args |> Map.put(:author_id, author)
           |> Map.put(:root_id, root)
           |> Map.put(:parent_id, parent)
    )
    query_author = User |> where([u], u.id == ^author)
    parent_update = fn ->
      query_parent = Post |> where([p], p.id == ^parent)
      Repo.update_all(query_parent, inc: [replies_count: 1])
    end

    Repo.transaction(fn ->
      with {:ok, post} <- Repo.insert(changeset),
           {_, _}      <- Repo.update_all(query_author, inc: [posts_count: 1]),
           {_, _}      <- if(parent, do: parent_update.(), else: {0, []})
      do
        create_or_update_process_topics(post, args, info)
        post
      else
        _ -> Repo.rollback("Error during post submitting.")
      end
    end)
  end

  # Process update

  def update(%{id: id} = args, info) do
    case Resolver.Post.find(%{id: id}, info) do
      {:ok, post} ->
        changeset = Post.changeset(post, args)

        Repo.transaction(fn ->
          with {:ok, post} <- Repo.update(changeset)
          do
            create_or_update_process_topics(post, args, info)
            post
          else
            _ -> Repo.rollback("Error during post editing.")
          end
        end)
      {:error, message} ->
        {:error, message}
    end
  end

  # Process create or update topics

  defp create_or_update_process_topics(post, %{topics: topics} = _args, info) do
    old_topics =
      Topic
      |> join(:inner, [t], pt in PostTopic)
      |> where([t, pt], pt.topic_id == t.id)
      |> where([t, pt], pt.post_id == ^post.id)
      |> where([t, pt], pt.is_deleted == false)
      |> order_by([t, pt], desc: pt.assigned_at, desc: pt.topic_id)
      |> Repo.all
    new_topics =
      Enum.map(topics, fn topic ->
        case Resolver.Topic.find(%{id: topic}, info) do
          {:ok, topic} ->
            topic
          {:error, message} ->
            Repo.rollback(message)
        end
      end)

    to_create = Enum.filter(new_topics, fn new_topic ->
      Enum.all?(old_topics, fn old_topic ->
        new_topic.id != old_topic.id  
      end)
    end)

    to_delete = Enum.filter(old_topics, fn old_topic ->
      Enum.all?(new_topics, fn new_topic ->
        old_topic.id != new_topic.id  
      end)
    end)

    Enum.each(to_delete, fn topic ->
      query =
        PostTopic
        |> where([pt], pt.post_id == ^post.id)
        |> where([pt], pt.topic_id == ^topic.id)
        |> where([pt], pt.is_deleted == false)
      query_topic = Topic |> where([t], t.id == ^topic.id)

      with {_, _} <- Repo.update_all(query, set: [is_deleted: true, deleted_at: Timex.now]),
           {_, _} <- Repo.update_all(query_topic, inc: [posts_count: -1])
      do
        :ok
      else
        _ -> Repo.rollback("Error during topics assign operations.")
      end
    end)

    Enum.each(to_create, fn topic ->
      changeset = PostTopic.changeset(%PostTopic{}, %{
        post_id: post.id,
        topic_id: topic.id
      })
      query_topic = Topic |> where([t], t.id == ^topic.id)

      with {:ok, _} <- Repo.insert(changeset),
           {_, _}   <- Repo.update_all(query_topic, inc: [posts_count: 1])
      do
        :ok
      else
        _ -> Repo.rollback("Error during topics assign operations.")
      end
    end)

    :ok
  end

  defp create_or_update_process_topics(_post, %{} = _args, _info),
    do: :ok
end
