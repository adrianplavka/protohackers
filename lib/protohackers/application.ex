defmodule Protohackers.Application do
  @moduledoc false

  use Application

  @tcp_options Application.compile_env!(:protohackers, :tcp_options)
  @port Keyword.fetch!(@tcp_options, :port)
  @read_timeout Keyword.get(@tcp_options, :read_timeout, 60_000)

  @impl true
  def start(_type, _args) do
    children = [
      {ThousandIsland,
       handler_module: Protohackers.BudgetChatProxy.Handler,
       port: @port,
       read_timeout: @read_timeout,
       transport_options: [packet: :line, buffer: 1024 * 100]}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
