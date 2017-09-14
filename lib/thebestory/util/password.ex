defmodule TheBestory.Util.Password do
  @moduledoc """
  This module is the interface for working with passwords.
  """

  alias Comeonin.Argon2

  @doc """
  Matches a raw and crypted password.
  """
  def match(raw, crypted),
    do: Argon2.checkpw(raw, crypted)

  @doc """
  Hash the password with a randomly generated salt.
  """
  def hash(password), 
    do: Argon2.hashpwsalt(password)
end
