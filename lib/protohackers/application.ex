defmodule Protohackers.Application do
  @moduledoc false

  use Application

  @tcp_options Application.compile_env!(:protohackers, :tcp_options)

  @impl true
  def start(_type, _args) do
    children = [
      {ThousandIsland,
       handler_module: Protohackers.Assets.Handler,
       port: Keyword.fetch!(@tcp_options, :port),
       read_timeout: Keyword.get(@tcp_options, :read_timeout, 5000),
       transport_options: [packet: :raw, buffer: 1024 * 100]}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
