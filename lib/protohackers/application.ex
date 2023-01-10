defmodule Protohackers.Application do
  @moduledoc false

  use Application

  @udp_options Application.compile_env!(:protohackers, :udp_options)
  @host Keyword.get(@udp_options, :host, "0.0.0.0")
  @port Keyword.fetch!(@udp_options, :port)

  @impl true
  def start(_type, _args) do
    children = [
      Protohackers.Database.Store,
      {Protohackers.Database.Server, host: @host, port: @port}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
