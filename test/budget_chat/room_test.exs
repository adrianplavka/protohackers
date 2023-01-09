defmodule Protohackers.BudgetChat.RoomTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.BudgetChat.Room

  test "should join a member & disallow the same username" do
    assert :ok = Room.join("voyage")
    assert :error = Room.join("voyage")
  end

  test "should join a member & notify other processes when user joins & leaves" do
    Task.async(fn ->
      assert :ok = Room.join("voyage")

      Task.async(fn ->
        assert :ok = Room.join("haxius")
      end)

      assert_receive {:join, "haxius"}
      assert_receive {:leave, "haxius"}
    end)
    |> Task.await()
  end

  test "should not return members when process isn't in process list" do
    assert :error = Room.members()
  end

  test "should join a member & output members excluding the process" do
    Task.async(fn ->
      assert :ok = Room.join("voyage")

      Task.async(fn ->
        assert :ok = Room.join("haxius")
        assert {:ok, ["voyage"]} = Room.members()
      end)
      |> Task.await()
    end)
    |> Task.await()
  end

  test "should broadcast messages between processes" do
    Task.async(fn ->
      assert :ok = Room.join("voyage")

      Task.async(fn ->
        assert :ok = Room.join("haxius")
        Room.broadcast_message("Hello")
      end)

      assert_receive {:message, "haxius", "Hello"}
    end)
    |> Task.await()
  end
end
