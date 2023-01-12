defmodule Protohackers.BudgetChatProxy.ModifierTest do
  use ExUnit.Case

  alias Protohackers.BudgetChatProxy.Modifier

  test "should rewrite an example" do
    assert "Hi alice, please send payment to 7YWHMfk9JZe0LM0g1ZauHuiSxhI" =
             Modifier.rewrite_address(
               "Hi alice, please send payment to 7iKDZEwPZSqIvDnHvVN2r0hUWXD5rHX"
             )

    assert "Hi alice, please send payment to 7YWHMfk9JZe0LM0g1ZauHuiSxhI and hurry up!" =
             Modifier.rewrite_address(
               "Hi alice, please send payment to 7iKDZEwPZSqIvDnHvVN2r0hUWXD5rHX and hurry up!"
             )

    assert "Hi alice, please send payment to 9iKDZEwPZSqIvDnHvVN2r0hUWXD5rHX" =
             Modifier.rewrite_address(
               "Hi alice, please send payment to 9iKDZEwPZSqIvDnHvVN2r0hUWXD5rHX"
             )
  end
end
