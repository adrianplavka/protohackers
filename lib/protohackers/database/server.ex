defmodule Protohackers.Database.Server do
  use GenServer

  alias Protohackers.Database.Request
  alias Protohackers.Database.Store

  require Logger

  # Client functions

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  # Server functions

  @impl GenServer
  def init(opts) do
    host = Keyword.get(opts, :host, "0.0.0.0") |> to_charlist()
    port = Keyword.fetch!(opts, :port)
    state = %{host: host, port: port, socket: nil}

    {:ok, state, {:continue, :open}}
  end

  @impl GenServer
  def handle_continue(:open, %{host: host, port: port} = state) do
    {:ok, ip} = :inet.getaddr(host, :inet, 5000)

    udp_options = [
      ip: ip,
      active: true,
      buffer: 1024 * 100,
      mode: :binary
    ]

    {:ok, socket} = :gen_udp.open(port, udp_options)
    {:noreply, %{state | socket: socket}}
  end

  @impl GenServer
  def handle_continue(_, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:udp, socket, ip, port, packet}, %{socket: socket} = state) do
    case Request.decode_payload(packet) do
      {:ok, :insert, key, value} ->
        Logger.info("Received an insert payload: key #{key}, value #{value}")
        Store.insert(key, value)

      {:ok, :retrieve, key} ->
        Logger.info("Received a retrieve payload: key #{key}")
        value = Store.retrieve(key)
        :gen_udp.send(socket, ip, port, "#{key}=#{value}")

      {:ok, :version} ->
        Logger.info("Received a version payload")
        version = Store.version()
        :gen_udp.send(socket, ip, port, "version=#{version}")

      other ->
        Logger.info("Received an unknown payload: #{packet}")
        other
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state}
  end
end
