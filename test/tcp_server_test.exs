defmodule Protohackers.TcpServerTest do
  use ExUnit.Case
  use ExUnitProperties

  import Protohackers.Utils

  @tcp_options Application.compile_env!(:protohackers, :tcp_options)
  @port Keyword.fetch!(@tcp_options, :port)

  test "should connect & be greeted" do
    assert {:ok, socket} = tcp_connect()
    tcp_disconnect_on_exit(socket)

    assert {:ok, msg} = tcp_recv(socket)
    assert msg =~ "Welcome"
  end

  test "should timeout after inactivity" do
    assert {:ok, socket} = tcp_connect()
    tcp_disconnect_on_exit(socket)

    assert {:ok, _} = tcp_recv(socket)
    assert {:error, :closed} = tcp_recv(socket)
  end

  test "should handle a valid username" do
    assert {:ok, socket} = tcp_connect()
    tcp_disconnect_on_exit(socket)

    assert {:ok, _} = tcp_recv(socket)

    assert :ok = tcp_send(socket, with_newline("voyage"))
    assert {:ok, msg} = tcp_recv(socket)

    assert msg =~ "The room contains"
  end

  property "should handle & disconnect an invalid username" do
    check all username <- filter(string(:printable), fn x -> not alphanumeric?(x) end) do
      assert {:ok, socket} = tcp_connect()
      tcp_disconnect_on_exit(socket)

      assert {:ok, _} = tcp_recv(socket)
      assert :ok = tcp_send(socket, with_newline(username))
      assert {:error, :closed} = tcp_recv(socket)
    end
  end

  test "should handle multiple users & output room list w/ new joined user message" do
    assert {:ok, socket1} = tcp_connect()
    tcp_disconnect_on_exit(socket1)

    assert {:ok, _} = tcp_recv(socket1)
    assert :ok = tcp_send(socket1, with_newline("voyage"))
    assert {:ok, _} = tcp_recv(socket1)

    assert {:ok, socket2} = tcp_connect()
    tcp_disconnect_on_exit(socket2)

    assert {:ok, _} = tcp_recv(socket2)
    assert :ok = tcp_send(socket2, with_newline("haxius"))
    assert {:ok, msg} = tcp_recv(socket2)

    assert msg =~ "The room contains: voyage"

    assert {:ok, msg} = tcp_recv(socket1)

    assert msg =~ "haxius has entered the room"
  end

  test "should handle multiple users & broadcast message to other users" do
    assert {:ok, socket1} = tcp_connect()
    tcp_disconnect_on_exit(socket1)

    assert {:ok, _} = tcp_recv(socket1)
    assert :ok = tcp_send(socket1, with_newline("voyage"))
    assert {:ok, _} = tcp_recv(socket1)

    assert {:ok, socket2} = tcp_connect()
    tcp_disconnect_on_exit(socket2)

    assert {:ok, _} = tcp_recv(socket2)
    assert :ok = tcp_send(socket2, with_newline("haxius"))
    assert {:ok, _} = tcp_recv(socket2)

    assert {:ok, _} = tcp_recv(socket1)

    assert :ok = tcp_send(socket1, with_newline("Hello"))
    assert {:ok, msg} = tcp_recv(socket2)

    assert msg =~ "[voyage] Hello"

    assert :ok = tcp_send(socket2, with_newline("Hey"))
    assert {:ok, msg} = tcp_recv(socket1)

    assert msg =~ "[haxius] Hey"
  end

  test "should handle messages when user leaves the room" do
    assert {:ok, socket1} = tcp_connect()
    tcp_disconnect_on_exit(socket1)

    assert {:ok, _} = tcp_recv(socket1)
    assert :ok = tcp_send(socket1, with_newline("voyage"))
    assert {:ok, _} = tcp_recv(socket1)

    assert {:ok, socket2} = tcp_connect()

    assert {:ok, _} = tcp_recv(socket2)
    assert :ok = tcp_send(socket2, with_newline("haxius"))
    assert {:ok, _} = tcp_recv(socket2)

    assert {:ok, _} = tcp_recv(socket1)

    assert :ok = tcp_disconnect(socket2)
    assert {:ok, msg} = tcp_recv(socket1)
    assert msg =~ "haxius has left the room"
  end

  defp tcp_connect,
    do: :gen_tcp.connect('localhost', @port, active: false)

  defp tcp_disconnect(socket),
    do: :gen_tcp.close(socket)

  defp tcp_disconnect_on_exit(socket),
    do: on_exit(fn -> tcp_disconnect(socket) end)

  defp tcp_recv(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> {:ok, to_string(data)}
      other -> other
    end
  end

  defp tcp_send(socket, data) do
    :gen_tcp.send(socket, data)
  end
end
