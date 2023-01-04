defmodule Protohackers.TCPServer do
  use GenServer

  @behaviour :ranch_protocol
  @timeout 5000

  def child_spec(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, name, [])
  end

  # Configuration

  @impl true
  def start_link(ref, transport, opts) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  @impl true
  def init({ref, transport, _opts}) do
    Process.flag(:trap_exit, true)

    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: :once)
    :gen_server.enter_loop(__MODULE__, [], {socket, transport}, @timeout)
  end

  @impl true
  def terminate(_reason, {socket, transport}) do
    transport.close(socket)
    :normal
  end

  # Server callbacks

  @impl true
  def handle_info({:tcp, socket, data}, {socket, transport} = state) do
    :ok = transport.send(socket, data)
    :ok = transport.setopts(socket, active: :once)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, _reason}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end
end
