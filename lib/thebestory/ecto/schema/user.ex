defmodule TheBestory.Ecto.Schema.User do
  @moduledoc false

  use TheBestory.Ecto.Schema

  alias TheBestory.Ecto.Schema.{Like, Post, User}
  alias TheBestory.Util.Password

  schema "users" do
    field :username,      :string
    field :nickname,      :string
    field :password,      :string

    field :posts_count,   :integer, default: 0
    field :likes_count,   :integer, default: 0

    field :is_protected,  :boolean, default: false
    field :is_suspended,  :boolean, default: false

    field :registered_at, Timex.Ecto.DateTime

    has_many :posts, Post, foreign_key: :author_id
    has_many :likes, Like
  end

  def changeset(struct, attrs \\ %{})
  def changeset(%User{} = user, attrs),
    do: user |> change |> changeset(attrs)
  def changeset(%Ecto.Changeset{} = changeset, attrs) do
    changeset
    |> cast(attrs, [:username, :nickname, :password, :is_protected, :is_suspended])
    |> validate_required([:username, :nickname, :password])
    |> validate_length(:username, min: 1, max: 64)
    |> validate_length(:nickname, min: 1, max: 64)
    |> validate_length(:password, min: 8, max: 255)
    |> put_registered_at_datetime
    |> maybe_put_password_hash
  end

  defp put_registered_at_datetime(%Ecto.Changeset{} = changeset) do
    case get_state(changeset) do
      :built -> put_change(changeset, :registered_at, Timex.now)
      _      -> changeset
    end
  end

  defp maybe_put_password_hash(%Ecto.Changeset{} = changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{password: password}} ->
        put_change(changeset, :password, Password.hash(password))
      _ ->
        changeset
    end
  end
end
