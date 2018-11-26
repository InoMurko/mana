defmodule ItestTest do
  use ExUnit.Case
  doctest Itest

  test "greets the world" do
    assert Itest.hello() == :world
  end
end
