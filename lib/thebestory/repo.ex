defmodule TheBestory.Repo do
  @moduledoc false

  use Ecto.Repo, otp_app: :thebestory

  @doc """
  Dynamically loads the database connection parameters from
  environment variables.
  """
  def init(_, opts) do
    {:ok, opts
          |> put_opt(:url,       "DATABASE_URL")
          |> put_opt(:pool_size, "DATABASE_POOL_SIZE")}
  end

  defp put_opt(opts, opt, env) do
    case System.get_env(env) do
      val when not is_nil(val) ->
        Keyword.put(opts, opt, val)
      _ ->
        opts
    end
  end
end
