defmodule PerformanceTest do
  use ExUnit.Case

  @tag :benchmark
  test "Bitmask Performance" do
    bitmask = MyBitmask.all()

    output = Benchee.run(
      %{
        "MyBitmask.none/0" => &MyBitmask.none/0,
        "MyBitmask.all/0" => &MyBitmask.all/0,
        "MyBitmask.get_all_values/0" => &MyBitmask.get_all_values/0,
        "MyBitmask.atom_to_bitmask/1" => fn -> MyBitmask.atom_to_bitmask(:flag_1) end,
        "MyBitmask.int_to_bitmask/1" => fn -> MyBitmask.int_to_bitmask(1) end,
        "MyBitmask.atom_flags_to_bitmask/1" => fn -> MyBitmask.atom_flags_to_bitmask([:flag_1, :flag_4]) end,
        "MyBitmask.has_flag/2" => fn -> MyBitmask.has_flag(bitmask, :flag_3) end,
        "MyBitmask.has_flag/2" => fn -> MyBitmask.has_flag(bitmask.bitmask, :flag_3) end,
      },

      print: %{
        benchmarking: true,
        fast_warning: false,
        configuration: true
      }
    )
  end

end
