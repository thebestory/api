defmodule TheBestory.Mixfile do
  use Mix.Project

  def project do
    [
      app: :thebestory,
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TheBestory.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies project dependencies.
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},

      {:ecto, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:snowflake, "~> 1.0.0"},
      {:timex, "~> 3.1"},
      {:timex_ecto, "~> 3.1"},
      {:jose, "~> 1.8"},
      {:joken, "~> 1.5"},
      {:comeonin, "~> 4.0"},
      {:argon2_elixir, "~> 1.2"},
      {:absinthe, "~> 1.3.0"},
      {:absinthe_ecto, "~> 0.1.2"},

      {:plug, "~> 1.4.3"},
      {:cowboy, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:absinthe_plug, "~> 1.3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    []
  end
end
