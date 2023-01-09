defmodule Protohackers.BudgetChat.Handler do
  use ThousandIsland.Handler

  alias ThousandIsland.Socket
  alias Protohackers.BudgetChat.Room

  import Protohackers.Utils

  require Logger

  @impl ThousandIsland.Handler
  def handle_connection(socket, _state) do
    state = %{joined?: false}
    Socket.send(socket, with_newline("Welcome to budgetchat! What shall I call you?"))

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, %{joined?: false} = state) do
    username = without_newline(data)

    with true <- valid_username?(username),
         :ok <- Room.join(username),
         {:ok, members} <- Room.members() do
      Socket.send(socket, with_newline("* The room contains: #{Enum.join(members, ", ")}"))
      {:continue, %{state | joined?: true}}
    else
      _ -> {:close, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(data, _socket, state) do
    data = without_newline(data)

    Room.broadcast_message(data)
    {:continue, state}
  end

  @impl GenServer
  def handle_info({:join, username}, {socket, state}) do
    Socket.send(socket, with_newline("* #{username} has entered the room"))
    {:noreply, {socket, state}}
  end

  @impl GenServer
  def handle_info({:message, username, message}, {socket, state}) do
    Socket.send(socket, with_newline("[#{username}] #{message}"))
    {:noreply, {socket, state}}
  end

  @impl GenServer
  def handle_info({:leave, username}, {socket, state}) do
    Socket.send(socket, with_newline("* #{username} has left the room"))
    {:noreply, {socket, state}}
  end

  defp valid_username?(username) do
    length = String.length(username)
    length > 0 and length <= 16 and alphanumeric?(username)
  end
end
