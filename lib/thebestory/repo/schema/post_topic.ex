defmodule TheBestory.Repo.Schema.PostTopic do
  @moduledoc false

  use TheBestory.Repo.Schema

  alias TheBestory.Repo.Schema.{Post, PostTopic, Topic}

  @primary_key false

  schema "posts_topics" do
    belongs_to :post,  Post
    belongs_to :topic, Topic

    field :assigned_at, Timex.Ecto.DateTime

    field :is_deleted,  :boolean, default: false
    field :deleted_at,  Timex.Ecto.DateTime
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%PostTopic{} = post_topic, attrs),
    do: post_topic |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:post_id, :topic_id, :is_deleted])
    |> validate_required([:post_id, :topic_id])
    |> put_assigned_at_datetime
    |> maybe_put_deleted_at_datetime
  end

  defp put_assigned_at_datetime(%Ecto.Changeset{} = changeset) do
    case get_state(changeset) do
      :built -> put_change(changeset, :assigned_at, Timex.now)
      _      -> changeset
    end
  end

  defp maybe_put_deleted_at_datetime(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{is_deleted: true}} ->
        put_change(changeset, :deleted_at, Timex.now)
      _ ->
        changeset
    end
  end
end
