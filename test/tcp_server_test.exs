defmodule Protohackers.TcpServerTest do
  use ExUnit.Case

  @tcp_options Application.compile_env!(:protohackers, :tcp_options)
  @port Keyword.fetch!(@tcp_options, :port)

  setup do
    {:ok, socket} = :gen_tcp.connect('localhost', @port, active: false)
    on_exit(fn -> :gen_tcp.close(socket) end)

    {:ok, socket: socket}
  end

  test "should successfully send & receive data", %{socket: socket} do
    content = "test" <> "\n"

    assert :ok = :gen_tcp.send(socket, content)
    assert {:ok, _} = :gen_tcp.recv(socket, 0)
  end

  test "should handle line data", %{socket: socket} do
    content = "{\"method\": \"isPrime\", \"number\":3}\n{\"method\":"

    assert :ok = :gen_tcp.send(socket, content)
    assert {:ok, '{"method":"isPrime","prime":true}\n'} = :gen_tcp.recv(socket, 0)

    assert :ok = :gen_tcp.send(socket, "\"isPrime\", \"number\":\"not prime\"}\n")
    assert {:ok, 'malformed response\n'} = :gen_tcp.recv(socket, 0)
  end

  test "should timeout", %{socket: socket} do
    content = "{\"method\": \"isPrime\","

    assert :ok = :gen_tcp.send(socket, content)
    assert {:error, _} = :gen_tcp.recv(socket, 0)
  end
end
