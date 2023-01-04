defmodule Protohackers.Application do
  @moduledoc false

  use Application

  @port Application.compile_env!(:protohackers, :port)

  @impl true
  def start(_type, _args) do
    children = [
      {Protohackers.TCPServer, port: @port}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end