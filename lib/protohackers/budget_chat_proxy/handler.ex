defmodule Protohackers.BudgetChatProxy.Handler do
  use ThousandIsland.Handler

  alias ThousandIsland.Socket
  alias Protohackers.BudgetChatProxy.Modifier

  import Protohackers.Utils

  require Logger

  @impl ThousandIsland.Handler
  def handle_connection(_socket, _state) do
    {:ok, proxy_socket} =
      :gen_tcp.connect('chat.protohackers.com', 16963,
        active: false,
        mode: :binary,
        packet: :line,
        buffer: 1024 * 100
      )

    proxy_task = Task.async(__MODULE__, :handle_proxy_data, [proxy_socket, self()])

    {:continue, %{proxy_socket: proxy_socket, proxy_task: proxy_task}}
  end

  def handle_proxy_data(socket, parent_pid) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        Process.send(parent_pid, {:proxy_data, data}, [])
        handle_proxy_data(socket, parent_pid)

      {:error, reason} ->
        Process.send(parent_pid, {:proxy_error, reason}, [])
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(data, _socket, %{proxy_socket: proxy_socket} = state) do
    data =
      data
      |> without_newline()
      |> Modifier.rewrite_address()
      |> with_newline()

    :gen_tcp.send(proxy_socket, data)

    {:continue, state}
  end

  @impl GenServer
  def handle_info({:proxy_data, data}, {socket, state}) do
    data =
      data
      |> without_newline()
      |> Modifier.rewrite_address()
      |> with_newline()

    Socket.send(socket, data)

    {:noreply, {socket, state}}
  end

  @impl GenServer
  def handle_info({:proxy_error, reason}, {socket, state}) do
    {:stop, reason, {socket, state}}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state}
  end

  @impl GenServer
  def terminate(reason, %{proxy_socket: proxy_socket, proxy_task: proxy_task}) do
    :gen_tcp.close(proxy_socket)
    Task.shutdown(proxy_task)

    reason
  end
end
