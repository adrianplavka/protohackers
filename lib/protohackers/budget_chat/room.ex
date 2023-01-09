defmodule Protohackers.BudgetChat.Room do
  use GenServer

  # Client functions

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def join(username, opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    timeout = Keyword.get(opts, :timeout, 5000)
    GenServer.call(server, {:join, username}, timeout)
  end

  def members(opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    timeout = Keyword.get(opts, :timeout, 5000)
    GenServer.call(server, :members, timeout)
  end

  def broadcast_message(message, opts \\ []) do
    server = Keyword.get(opts, :server, __MODULE__)
    GenServer.cast(server, {:message, self(), message})
  end

  # Server functions

  @impl GenServer
  def init(_opts) do
    state = %{users: %{}, user_pids: %{}}
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:join, username}, {pid, _}, state) do
    if Map.has_key?(state.users, username) do
      {:reply, :error, state}
    else
      Process.monitor(pid)

      Enum.each(state.user_pids, fn {client_pid, _} ->
        Process.send(client_pid, {:join, username}, [])
      end)

      {:reply, :ok,
       %{
         state
         | users: Map.put_new(state.users, username, pid),
           user_pids: Map.put_new(state.user_pids, pid, username)
       }}
    end
  end

  @impl GenServer
  def handle_call(:members, {pid, _}, state) do
    username = Map.get(state.user_pids, pid)

    if username do
      members =
        state.users
        |> Map.delete(username)
        |> Enum.map(fn {username, _} -> username end)

      {:reply, {:ok, members}, state}
    else
      {:reply, :error, state}
    end
  end

  @impl GenServer
  def handle_call(_, _, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:message, pid, message}, state) do
    username = Map.get(state.user_pids, pid)

    if username do
      Enum.each(state.user_pids, fn {client_pid, _} ->
        if client_pid != pid,
          do: Process.send(client_pid, {:message, username, message}, [])
      end)
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(_, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    username = Map.get(state.user_pids, pid)

    if username do
      Enum.each(state.user_pids, fn {client_pid, _} ->
        if client_pid != pid,
          do: Process.send(client_pid, {:leave, username}, [])
      end)
    end

    {:noreply,
     %{
       state
       | users: Map.delete(state.users, username),
         user_pids: Map.delete(state.user_pids, pid)
     }}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state}
  end
end
