defmodule TheBestory.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias TheBestory.GraphQL.Resolver

  import_types TheBestory.GraphQL.Scalar
  import_types TheBestory.GraphQL.Type

  query do
    @desc "Get a user by it's Snowflake ID."
    field :user, :user do
      @desc "User's Snowflake ID."
      arg :id, :snowflake

      @desc "User's username."
      arg :username, :string

      resolve &Resolver.User.find/2
    end

    @desc "List users."
    field :users, list_of(:user) do
      @desc "User's Snowflake ID, before which to list the users."
      arg :before, :snowflake

      @desc "User's Snowflake ID, after which to list the users."
      arg :after, :snowflake

      @desc "Number of users in the list."
      arg :limit, :integer, default_value: 100

      resolve &Resolver.User.list/2
    end

    @desc "Get a topic by it's Snowflake ID."
    field :topic, :topic do
      @desc "Topic's Snowflake ID."
      arg :id, :snowflake

      @desc "Topic's slug."
      arg :slug, :string

      resolve &Resolver.Topic.find/2
    end

    @desc "List topics."
    field :topics, list_of(:topic) do
      @desc "Topic's Snowflake ID, before which to list the topics."
      arg :before, :snowflake

      @desc "Topic's Snowflake ID, after which to list the topics."
      arg :after, :snowflake

      @desc "Number of topics in the list."
      arg :limit, :integer, default_value: 100

      resolve &Resolver.Topic.list/2
    end

    @desc "Get a post by it's Snowflake ID."
    field :post, :post do
      @desc "Post's Snowflake ID."
      arg :id, :snowflake

      resolve &Resolver.Post.find/2
    end

    @desc "List posts."
    field :posts, list_of(:post) do
      @desc "Listing type of the posts."
      arg :type, :post_listing_type, default_value: :latest

      @desc "Snowflake IDs of authors of posts."
      arg :authors, list_of(non_null(:snowflake))

      @desc "Snowflake IDs of topics of posts."
      arg :topics, list_of(non_null(:snowflake))

      @desc "Post's Snowflake ID, before which to list the posts."
      arg :before, :snowflake

      @desc "Post's Snowflake ID, after which to list the posts."
      arg :after, :snowflake

      @desc "Number of posts in the list."
      arg :limit, :integer, default_value: 100

      resolve &Resolver.Post.list/2
    end
  end
end
