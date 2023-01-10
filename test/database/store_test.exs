defmodule Protohackers.Database.StoreTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.Database.Store

  setup do
    on_exit(fn -> Store.drop() end)
  end

  property "should insert a new key w/ value" do
    check all key <- string(:alphanumeric), value <- string(:alphanumeric) do
      Store.insert(key, value)
      assert value == Store.retrieve(key)
    end
  end

  property "should retrieve a nil value when key doesn't exist" do
    check all key <- string(:alphanumeric) do
      assert nil == Store.retrieve(key)
    end
  end

  property "should overwrite an existing value with a new value" do
    check all key <- string(:alphanumeric),
              old_value <- string(:alphanumeric),
              new_value <- string(:alphanumeric) do
      Store.insert(key, old_value)
      assert old_value == Store.retrieve(key)

      Store.insert(key, new_value)
      assert new_value == Store.retrieve(key)
    end
  end

  test "should retrieve version" do
    version = Store.version()
    assert is_binary(version)
  end
end
