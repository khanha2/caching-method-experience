defmodule HugeSellerApiTest do
  use ExUnit.Case
  doctest HugeSellerApi

  test "greets the world" do
    assert HugeSellerApi.hello() == :world
  end
end
