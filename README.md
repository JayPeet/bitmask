# Bitmask

A bitmask implementation for elixir, with optional Ecto support.

## Usage

### Define your bitmask

```elixir
defmodule MyBitmask do
  use Bitmask, [
    :flag_1,
    :flag_2,
    :flag_3,
    :flag_4,
  ]
end
```

### Create your bitmask
```elixir
iex> bitmask = MyBitmask.atom_flags_to_bitmask([:flag_1, :flag_3])
%MyBitmask{bitmask: 5, flags: [:flag_1, :flag_3]}
```

See the docs for more info.
Issues / PRs / Feedback welcome.