defmodule TheBestory.Util.JWT do
  @moduledoc """
  This module is the interface for working with JSON Web Tokens.
  """

  import Joken
  
  alias TheBestory.Util.Snowflake

  @doc """
  Creates a new JWT with given payload and signs it.
  """
  def encode(%{} = payload \\ %{}) do
    %{}
    |> token
    |> with_jti(Snowflake.next!())
    |> with_iss(issuer())
    |> with_claim("pld", payload)
    |> with_signer(hs256(secret_key()))
    |> sign
    |> get_compact
  end

  @doc """
  Decodes an existing JWT and verifies it.
  """
  def decode(encoded_token) do
    encoded_token
    |> token
    |> with_validation("iss", &(&1 == issuer()))
    |> with_signer(hs256(secret_key()))
    |> verify
    |> extract_payload_or_error
  end

  @doc """
  Decodes an existing JWT and returns JTI.
  """
  def get_jti(encoded_token) do
    encoded_token
    |> token
    |> with_signer(hs256(secret_key()))
    |> peek
    |> Map.fetch!("jti")
  end

  defp extract_payload_or_error(verified_token) do
    unless verified_token.error do
      {:ok, Map.get(verified_token.claims, "pld", %{})}
    else
      {:error, verified_token.error}
    end
  end

  defp configuration,
    do: Application.get_env(:thebestory, __MODULE__, %{})

  defp issuer,
    do: configuration() |> Keyword.fetch!(:issuer)

  defp secret_key,
    do: configuration() |> Keyword.fetch!(:secret_key)
end
