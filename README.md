# Bitmask
[![Hex.pm](https://img.shields.io/hexpm/v/bitmask.svg)](https://hex.pm/packages/bitmask)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightblue.svg)](https://hexdocs.pm/bitmask/)

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

### Check if we have a flag
```elixir
iex> MyBitmask.has_flag(bitmask, :flag_1])
true
```

### Store it in an Ecto schema
```elixir
defmodule SomeEctoSchema do
  use Ecto.Schema
  schema "bitmasks" do
    field :my_bitmask, MyBitmask
  end
end
```

See the docs for more info.
Issues / PRs / Feedback welcome.