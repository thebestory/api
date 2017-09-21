defmodule TheBestory.Repo.Schema.Like do
  @moduledoc false

  use TheBestory.Repo.Schema

  alias TheBestory.Repo.Schema.{Like, Post, User}

  @primary_key false

  schema "likes" do
    belongs_to :user, User
    belongs_to :post, Post

    field :liked_at,   Timex.Ecto.DateTime
  
    field :is_unliked, :boolean, default: false
    field :unliked_at, Timex.Ecto.DateTime
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%Like{} = like, attrs),
    do: like |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:user_id, :post_id, :is_unliked])
    |> validate_required([:user_id, :post_id])
    |> put_liked_at_datetime
    |> maybe_put_unliked_at_datetime
  end

  defp put_liked_at_datetime(%Ecto.Changeset{} = changeset) do
    case get_state(changeset) do
      :built -> put_change(changeset, :liked_at, Timex.now)
      _      -> changeset
    end
  end

  defp maybe_put_unliked_at_datetime(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{is_unliked: true}} ->
        put_change(changeset, :unliked_at, Timex.now)
      _ ->
        changeset
    end
  end
end
