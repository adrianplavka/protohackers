defmodule Protohackers.TcpServer do
  @moduledoc """
  Implementation of TCP server using Ranch library.

  This module is responsible for accepting incoming connections & sending data
  back to the client.

  This module can be appended to the application's supervisor tree like:

      {Protohackers.TcpServer, port: @port, callback_module: Protohackers.TcpCallback}

  where `port` is required under which the server will accept incoming connections &
  `callback_mdoule` is required, which will delegate incoming data for further processing
  (refer to the Protohackers.TcpServer.Callback behaviour for more information).

  You can also specify a name, under which process will be spawned:

      {Protohackers.TcpServer, port: @port, callback_module: Protohackers.TcpCallback, name: TcpServer}
  """

  use GenServer

  @behaviour :ranch_protocol
  @timeout 5000

  # Configuration

  def child_spec(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    port = Keyword.get(opts, :port)
    ranch_opts = [port: port]

    :ranch.child_spec(__MODULE__, :ranch_tcp, ranch_opts, name, opts)
  end

  @impl true
  def start_link(ref, transport, opts) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  @impl true
  def init({ref, transport, opts}) do
    Process.flag(:trap_exit, true)
    callback_module = Keyword.fetch!(opts, :callback_module)

    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: :once)

    :gen_server.enter_loop(
      __MODULE__,
      [],
      %{socket: socket, transport: transport, callback_module: callback_module},
      @timeout
    )
  end

  # Server callbacks

  @impl true
  def handle_info(
        {:tcp, socket, data},
        %{socket: socket, transport: transport, callback_module: callback_module} = state
      ) do
    {outcome, data} = apply(callback_module, :handle_data, [data])
    :ok = transport.send(socket, data)
    :ok = transport.setopts(socket, active: :once)

    case outcome do
      :continue -> {:noreply, state}
      _ -> {:stop, :shutdown, state}
    end
  end

  @impl true
  def handle_info({:tcp_closed, socket}, %{socket: socket, transport: transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, _reason}, %{socket: socket, transport: transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{socket: socket, transport: transport}) do
    transport.close(socket)
    :normal
  end
end
