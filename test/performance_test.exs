defmodule PerformanceTest do
  use ExUnit.Case

  @doc """
  test "Bitmask.none() Performance" do
    Benchee.run(
      %{
        "Bitmask.none()" => MyBitmask.none()
      }
    )
  end
  """
end
