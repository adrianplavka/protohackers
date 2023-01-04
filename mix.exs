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
      {:ranch, "~> 2.1"}
    ]
  end

  defp aliases do
    [
      "test.watch": ["cmd fswatch lib test | mix test --listen-on-stdin --color"]
    ]
  end
end
