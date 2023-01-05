defmodule Protohackers.TcpServerTest do
  use ExUnit.Case

  @port Application.compile_env!(:protohackers, :port)

  setup do
    {:ok, socket} = :gen_tcp.connect('localhost', @port, active: false)
    on_exit(fn -> :gen_tcp.close(socket) end)

    {:ok, socket: socket}
  end

  test "should successfully send & receive data", %{socket: socket} do
    content = "test"

    assert :ok = :gen_tcp.send(socket, content)
    assert {:ok, _} = :gen_tcp.recv(socket, 0)
  end
end
