defmodule TheBestory.GraphQL.Resolver.Like do
  @moduledoc false

  use TheBestory.GraphQL.Resolver

  alias TheBestory.GraphQL.Resolver
  alias TheBestory.Repo.Schema.{Like, Post, User}

  # Process create

  def create(%{user: user_id, post: post_id} = _args, _info) do
    with user when not is_nil(user) <- Repo.get(User, user_id),
         post when not is_nil(post) <- Repo.get(Post, post_id)
    do
      query = Like
              |> where([l], l.user_id == ^user.id)
              |> where([l], l.post_id == ^post.id)
              |> where([l], l.is_unliked == false)
              |> order_by([l], desc: l.liked_at)

      case Repo.all(query) do
        [like | _] ->
          {:ok, like}
        _ ->
          changeset = Like.changeset(%Like{}, %{
            user_id: user.id,
            post_id: post.id
          })
          query_user = User |> where([u], u.id == ^user.id)
          query_post = Post |> where([p], p.id == ^post.id)

          Repo.transaction(fn ->
            with {:ok, like} <- Repo.insert(changeset),
                 {_, _}      <- Repo.update_all(query_user, inc: [likes_count: 1]),
                 {_, _}      <- Repo.update_all(query_post, inc: [likes_count: 1])
            do
             like
            else
              _ -> Repo.rollback("Error during like submitting.")
            end
          end)
      end
    else
      _ -> {:error, "User or post is not found."}
    end
  end

  def create(%{post: _} = args, info) do
    case info do
      %{context: %{authorization: %{user: %{id: id}}}} ->
        Resolver.Like.create(Map.put(args, :user, id), info)
      _ ->
        {:error, "User's Snowflake ID must be specified to like a post."}
    end
  end

  # Process delete

  def delete(%{user: user_id, post: post_id} = _args, _info) do
    with user when not is_nil(user) <- Repo.get(User, user_id),
         post when not is_nil(post) <- Repo.get(Post, post_id)
    do
      query = Like
              |> where([l], l.user_id == ^user.id)
              |> where([l], l.post_id == ^post.id)
              |> where([l], l.is_unliked == false)

      case Repo.all(query |> order_by([l], desc: l.liked_at)) do
        [like | _] ->
          query_user = User |> where([u], u.id == ^user.id)
          query_post = Post |> where([p], p.id == ^post.id)

          Repo.transaction(fn ->
            with {_, _} <- Repo.update_all(query, set: [is_unliked: true, unliked_at: Timex.now]),
                 {_, _} <- Repo.update_all(query_user, inc: [likes_count: -1]),
                 {_, _} <- Repo.update_all(query_post, inc: [likes_count: -1])
            do
              %{like | is_unliked: true, unliked_at: Timex.now}
            else
              _ -> Repo.rollback("Error during unlike submitting.")
            end
          end)
        _ ->
          {:error, "Like not found."}
      end
    else
      _ -> {:error, "User or post is not found."}
    end
  end

  def delete(%{post: _} = args, info) do
    case info do
      %{context: %{authorization: %{user: %{id: id}}}} ->
        Resolver.Like.delete(Map.put(args, :user, id), info)
      _ ->
        {:error, "User's Snowflake ID must be specified to unlike a post."}
    end
  end
end
