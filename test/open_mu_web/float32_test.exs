defmodule OpenMuWeb.Float32Test do
  use ExUnit.Case, async: true

  alias OpenMuWeb.Float32

  test "whole numbers become integers (JavaScript prints 385, not 385.0)" do
    assert Float32.normalize(385.0) === 385
    assert Float32.normalize(0.0) === 0
    assert Float32.normalize(-2.0) === -2
    assert Float32.normalize(7) === 7
  end

  test "non-whole float4 values use the shortest decimal (like node-postgres text)" do
    # 0.1 stored as real is decoded by Postgrex as 0.10000000149011612
    <<as_float4::float-32>> = <<0.1::float-32>>
    assert as_float4 != 0.1
    assert Float32.normalize(as_float4) === 0.1
    assert Float32.normalize(1.5) === 1.5
  end

  test "display/1" do
    assert Float32.display(400.0) == "400"
    assert Float32.display(nil) == ""
  end
end
