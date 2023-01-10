defmodule Protohackers.Database.Store do
  use GenServer

  # Client functions

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def insert(key, value, opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    GenServer.cast(server, {:insert, key, value})
  end

  def retrieve(key, opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    timeout = Keyword.get(opts, :timeout, 5000)
    GenServer.call(server, {:retrieve, key}, timeout)
  end

  def drop(opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    GenServer.cast(server, :drop)
  end

  def version(opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    timeout = Keyword.get(opts, :timeout, 5000)
    GenServer.call(server, :version, timeout)
  end

  # Server functions

  @impl GenServer
  def init(_opts) do
    state = %{}
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:insert, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_cast(:drop, _) do
    {:noreply, %{}}
  end

  @impl GenServer
  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:retrieve, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer
  def handle_call(:version, _, state) do
    {:reply, "Voyage's Key-Value Store 1.0", state}
  end

  @impl GenServer
  def handle_call(_, _, state) do
    {:noreply, state}
  end
end
