defmodule Protohackers.Database.ServerTest do
  use ExUnit.Case

  alias Protohackers.Database.Store

  @udp_options Application.compile_env!(:protohackers, :udp_options)
  @port Keyword.fetch!(@udp_options, :port)

  setup do
    on_exit(fn -> Store.drop() end)
  end

  test "should connect & receive data" do
    socket = udp_connect()
    udp_disconnect_on_exit(socket)

    assert :ok = udp_send(socket, "key")
    assert {:ok, _} = udp_recv(socket)
  end

  test "should set a key to a value" do
    socket = udp_connect()
    udp_disconnect_on_exit(socket)

    assert :ok = udp_send(socket, "key=value")
    assert :ok = udp_send(socket, "key")
    assert {:ok, "key=value"} = udp_recv(socket)
  end

  test "should retrieve a nil value when key does not exist" do
    socket = udp_connect()
    udp_disconnect_on_exit(socket)

    assert :ok = udp_send(socket, "key")
    assert {:ok, "key="} = udp_recv(socket)
  end

  test "should retrieve a version" do
    socket = udp_connect()
    udp_disconnect_on_exit(socket)

    assert :ok = udp_send(socket, "version")
    assert {:ok, version} = udp_recv(socket)
    assert version =~ "version="
  end

  test "should not allow inserting a version key" do
    socket = udp_connect()
    udp_disconnect_on_exit(socket)

    assert :ok = udp_send(socket, "version=value")
    assert {:error, _} = udp_recv(socket)
  end

  defp udp_connect do
    udp_options = [
      active: false,
      buffer: 1024 * 100,
      mode: :binary
    ]

    assert {:ok, socket} = :gen_udp.open(5003, udp_options)
    assert :ok = :gen_udp.connect(socket, 'localhost', @port)
    socket
  end

  defp udp_disconnect(socket),
    do: :gen_udp.close(socket)

  defp udp_disconnect_on_exit(socket),
    do: on_exit(fn -> udp_disconnect(socket) end)

  defp udp_recv(socket) do
    case :gen_udp.recv(socket, 0, 100) do
      {:ok, {_host, _port, data}} -> {:ok, data}
      other -> other
    end
  end

  defp udp_send(socket, data),
    do: :gen_udp.send(socket, data)
end
