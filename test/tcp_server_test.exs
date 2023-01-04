defmodule Protohackers.TcpServerTest do
  use ExUnit.Case

  @port Application.compile_env!(:protohackers, :port)

  setup do
    {:ok, socket} = :gen_tcp.connect('localhost', @port, active: false)
    on_exit(fn -> :gen_tcp.close(socket) end)

    {:ok, socket: socket}
  end

  test "should echo the same contents back multiple times", %{socket: socket} do
    content = "test"

    Enum.each(1..5, fn _ ->
      assert :ok = :gen_tcp.send(socket, content)
      assert {:ok, reply} = :gen_tcp.recv(socket, 0)

      assert reply == to_charlist(content)
    end)
  end
end
