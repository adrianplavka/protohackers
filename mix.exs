defmodule Protohackers.MixProject do
  use Mix.Project

  def project do
    [
      app: :protohackers,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Protohackers.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.9"},
      {:jason, "~> 1.4"},
      {:stream_data, "~> 0.5", only: :test},
      {:thousand_island, "~> 0.5.14"}
    ]
  end

  defp aliases do
    [
      "test.watch": ["cmd fswatch lib test | mix test --listen-on-stdin --color"]
    ]
  end
end
