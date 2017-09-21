defmodule TheBestory.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias TheBestory.GraphQL.Resolver

  import_types TheBestory.GraphQL.Scalar
  import_types TheBestory.GraphQL.Type

  query do
    @desc "Get a user by it's Snowflake ID or username."
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

    @desc "Get a topic by it's Snowflake ID or slug."
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

  mutation do
    @desc "Sign up a user."
    field :create_user, :user do
      @desc "Unique user's handle."
      arg :username, non_null(:string)

      @desc "User's nickname."
      arg :nickname, :string

      @desc "User's password."
      arg :password, non_null(:string)

      @desc "A flag indicating the profile will be closed from viewing by others."
      arg :is_protected, :boolean, default_value: false

      resolve &Resolver.User.create/2
    end

    @desc "Update the user."
    field :update_user, :user do
      @desc "User's Snowflake ID to update. Can be omitted if it need to update the currently authorized user."
      arg :id, :snowflake

      @desc "Unique user's handle."
      arg :username, :string

      @desc "User's nickname."
      arg :nickname, :string

      @desc "User's password."
      arg :password, :string

      @desc "A flag indicating the profile is closed from viewing by others."
      arg :is_protected, :boolean

      resolve &Resolver.User.update/2
    end

    @desc "Log in a user."
    field :create_session, :session do
      @desc "User's handle."
      arg :username, non_null(:string)

      @desc "User's password."
      arg :password, non_null(:string)

      resolve &Resolver.Session.create/2
    end

    @desc "Create a topic."
    field :create_topic, :topic do
      @desc "Topic's name."
      arg :title, non_null(:string)

      @desc "Topic's unique slug."
      arg :slug, non_null(:string)

      @desc "Topic's description."
      arg :description, non_null(:string)
        
      @desc "A flag indicating the topic will be public."
      arg :is_public, :boolean, default_value: false

      resolve &Resolver.Topic.create/2
    end

    @desc "Update the topic."
    field :update_topic, :topic do
      @desc "Topic's Snowflake ID to update."
      arg :id, non_null(:snowflake)

      @desc "Topic's name."
      arg :title, :string

      @desc "Topic's unique slug."
      arg :slug, :string

      @desc "Topic's description."
      arg :description, :string
        
      @desc "A flag indicating the topic is public."
      arg :is_public, :boolean

      resolve &Resolver.Topic.update/2
    end

    @desc "Create a post."
    field :create_post, :post do
      @desc "Author's of the post Snowflake ID or empty if currently authorized user is author."
      arg :author, :snowflake

      @desc "The post's for which reply is (parent post) Snowflake ID or empty if it isn't a reply."
      arg :parent, :snowflake

      @desc "List of post's topics' Snowflake IDs."
      arg :topics, list_of(non_null(:snowflake))

      @desc "Text of the post."
      arg :content, non_null(:string)

      @desc "A flag indicating the post will be published."
      arg :is_published, :boolean, default_value: false

      @desc "Date and time when post will be published."
      arg :published_at, :datetime

      resolve &Resolver.Post.create/2
    end

    @desc "Update the post."
    field :update_post, :post do
      @desc "Post's Snowflake ID to update."
      arg :id, non_null(:snowflake)

      @desc "List of post's topics' Snowflake IDs. It will be ignored, if it's a reply post."
      arg :topics, list_of(non_null(:snowflake))

      @desc "Text of the post."
      arg :content, :string

      @desc "A flag indicating the post is published."
      arg :is_published, :boolean

      @desc "Date and time when post was published."
      arg :published_at, :datetime

      @desc "A flag indicating the post is deleted."
      arg :is_deleted, :boolean

      resolve &Resolver.Post.update/2
    end

    @desc "Like a post."
    field :like_post, :like do
      @desc "User's Snowflake ID who is liking. Can be omitted if currently authorized user is liking."
      arg :user, :snowflake

      @desc "The post's Snowflake ID to like."
      arg :post, non_null(:snowflake)

      resolve &Resolver.Like.create/2
    end

    @desc "Unlike a post."
    field :unlike_post, :like do
      @desc "User's Snowflake ID who is unliking. Can be omitted if currently authorized user is unliking."
      arg :user, :snowflake

      @desc "The post's Snowflake ID to like."
      arg :post, non_null(:snowflake)

      resolve &Resolver.Like.delete/2
    end
  end
end
