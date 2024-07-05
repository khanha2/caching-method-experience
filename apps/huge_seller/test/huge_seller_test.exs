defmodule HugeSellerTest do
  use ExUnit.Case
  doctest HugeSeller

  test "greets the world" do
    assert HugeSeller.hello() == :world
  end
end
