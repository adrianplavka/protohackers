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
    insert_content = create_insert_payload(12345, 101)
    assert :ok = :gen_tcp.send(socket, insert_content)

    insert_content = create_insert_payload(12346, 102)
    assert :ok = :gen_tcp.send(socket, insert_content)

    insert_content = create_insert_payload(12347, 100)
    assert :ok = :gen_tcp.send(socket, insert_content)

    insert_content = create_insert_payload(40960, 5)
    assert :ok = :gen_tcp.send(socket, insert_content)

    query_content = create_query_payload(12288, 16384)
    assert :ok = :gen_tcp.send(socket, query_content)

    assert {:ok, [0x00, 0x00, 0x00, 0x65]} = :gen_tcp.recv(socket, 0)
  end

  test "should timeout after inactivity", %{socket: socket} do
    assert {:error, :closed} = :gen_tcp.recv(socket, 0)
  end

  test "should handle partial data", %{socket: socket} do
    assert :ok = :gen_tcp.send(socket, "I")
    assert :ok = :gen_tcp.send(socket, <<0>>)
    assert :ok = :gen_tcp.send(socket, <<0>>)
    assert :ok = :gen_tcp.send(socket, "0")
    assert :ok = :gen_tcp.send(socket, "9")
    :timer.sleep(10)
    assert :ok = :gen_tcp.send(socket, <<0>>)
    assert :ok = :gen_tcp.send(socket, <<0>>)
    assert :ok = :gen_tcp.send(socket, "0")
    assert :ok = :gen_tcp.send(socket, "0")

    query_content = create_query_payload(0, 20000)
    assert :ok = :gen_tcp.send(socket, query_content)

    assert {:ok, [0, 0, 48, 48]} = :gen_tcp.recv(socket, 0)
  end

  defp create_insert_payload(timestamp, price) do
    <<"I", timestamp::size(32), price::size(32)>>
  end

  defp create_query_payload(min_timestamp, max_timestamp) do
    <<"Q", min_timestamp::size(32), max_timestamp::size(32)>>
  end
end
