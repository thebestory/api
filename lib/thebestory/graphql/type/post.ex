defmodule TheBestory.GraphQL.Type.Post do
  @moduledoc false

  use Absinthe.Ecto, repo: TheBestory.Repo
  use Absinthe.Schema.Notation

  alias TheBestory.GraphQL.Resolver

  @desc """
  Posts is the main content on The Bestory.
  """
  object :post do
    @desc "Snowflake ID of the post."
    field :id, :snowflake

    @desc "Author of the post."
    field :author, :user, resolve: assoc(:author)

    @desc "The root post in the hierarchy of replies."
    field :root, :post, resolve: assoc(:root)

    @desc "The post for which reply is (parent post)."
    field :parent, :post, resolve: assoc(:parent)

    @desc "Text of the post."
    field :content, :string

    @desc "Number of replies to this post."
    field :replies_count, :integer

    @desc "Number of post's likes."
    field :likes_count, :integer

    @desc "A flag indicating current authorized user liked this post."
    field :is_liked, :boolean

    @desc "A flag indicating the post is published."
    field :is_published, :boolean

    @desc "A flag indicating the post is deleted."
    field :is_deleted, :boolean

    @desc "Date and time when post was submitted."
    field :submitted_at, :datetime

    @desc "Date and time when post was published."
    field :published_at, :datetime

    @desc "Date and time when post was edited (or null otherwise)."
    field :edited_at, :datetime

    @desc "Date and time when post was deleted (or null otherwise)."
    field :deleted_at, :datetime

    @desc "List of post's topics."
    field :topics, list_of(:topic) do
      @desc "Topic's Snowflake ID, before which to list the topics."
      arg :before, :snowflake

      @desc "Topic's Snowflake ID, after which to list the topics."
      arg :after, :snowflake

      @desc "Number of topics in the list."
      arg :limit, :integer, default_value: 100

      resolve fn args, info ->
        import Ecto.Query
        alias TheBestory.Repo
        alias TheBestory.Repo.Schema.{PostTopic, Topic}
  
        {:ok, Resolver.Topic.list(Topic, args, info)
              |> join(:inner, [t], pt in PostTopic)
              |> where([t, pt], pt.topic_id == t.id)
              |> where([t, pt], pt.post_id == ^info.source.id)
              |> where([t, pt], pt.is_deleted == false)
              |> order_by([t, pt], desc: pt.assigned_at, desc: pt.topic_id)
              |> Repo.all}
      end
    end

    @desc "List of users liked the post."
    field :likes, list_of(:like), resolve: assoc(:likes, fn query, _root, _ctx ->
      import Ecto.Query
      query
      |> where([l], l.is_unliked == false)
      |> order_by([l], desc: l.liked_at, desc: l.user_id)
    end)

    @desc "List of post's replies."
    field :replies, list_of(:post) do
      @desc "Listing type of the replies."
      arg :type, :post_listing_type, default_value: :latest

      @desc "Snowflake IDs of authors of replies."
      arg :authors, list_of(non_null(:snowflake))

      @desc "Post's Snowflake ID, before which to list the replies."
      arg :before, :snowflake

      @desc "Post's Snowflake ID, after which to list the replies."
      arg :after, :snowflake

      @desc "Number of replies in the list."
      arg :limit, :integer, default_value: 100

      resolve fn args, info ->
        Resolver.Post.list(Map.put(args, :parents, [info.source.id]), info)
      end
    end
  end

  @desc """
  Listing type of the posts.
  """
  enum :post_listing_type do
    @desc "Latest posts."
    value :latest

    @desc "Top posts."
    value :top

    @desc "Hot posts."
    value :hot

    @desc "Random posts."
    value :random
  end
end
