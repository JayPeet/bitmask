defmodule Bitmask do
  @moduledoc """
    A use macro for automatically generating a Bitmask from a collection of atoms, with support for saving them to a database via the provided Ecto.Type.

    You can create a bitmask like so:
      defmodule MyBitmask do
        use Bitmask, [
          :flag_1,
          :flag_2,
          :flag_3,
          :flag_4,
        ]
      end

    Or, you can define specific values for each field:
      defmodule MyBitmask do
        import Bitwise
        use Bitmask, [
          flag_1: 1 <<< 0,
          flag_2: 1 <<< 1,
          flag_3: 1 <<< 2,
          flag_4: 1 <<< 3,
        ]
      end

    The generated bitmask can also optionally be used with ecto. It stores the flags in the database as a bigint:
      defmodule SomeEctoSchema do
        use Ecto.Schema
        schema "bitmasks" do
          field :my_bitmask, MyBitmask
        end
      end
  """

  defstruct bitmask: 0, flags: []

  @type t() :: %Bitmask{
          bitmask: integer(),
          flags: list(:atom)
        }

  defp validate_bit_vals({{atom, value}, _i}) do
    {atom, value}
  end

  defp validate_bit_vals({atom, i}) do
    {atom, Bitwise.<<<(1, i)}
  end

  defmacro __using__(bit_vals) do
    bit_vals =
      Enum.with_index(bit_vals)
      |> Enum.map(&validate_bit_vals/1)

    atom_to_bitmask =
      Enum.reduce(bit_vals, [], fn {atom, value}, acc ->
        acc ++
          [
            quote do
              def atom_to_bitmask(unquote(atom)) do
                unquote(value)
              end
            end
          ]
      end)

    all_bitmask =
      Enum.reduce(bit_vals, %Bitmask{bitmask: 0, flags: []}, fn {atom, value},
                                                         %Bitmask{bitmask: bitmask, flags: flags} ->
        {val, _} = Code.eval_quoted(value, [], __CALLER__)
        %Bitmask{bitmask: bitmask + val, flags: flags ++ [atom]}
      end)

    ecto_code =
      if Code.ensure_loaded?(Ecto.Type) do
        quote do
          use Ecto.Type
          def type, do: :bigint

          def cast(bitmask) when is_integer(bitmask) do
            {:ok, int_to_bitmask(bitmask)}
          end

          def cast(%Bitmask{} = bitmask) do
            {:ok, bitmask}
          end

          def cast(_), do: :error

          def load(bitmask) when is_integer(bitmask) do
            {:ok, int_to_bitmask(bitmask)}
          end

          def load(_) do
            :error
          end

          def dump(%Bitmask{bitmask: bitmask, flags: _atom_flags}) do
            {:ok, bitmask}
          end

          def dump(bitmask) when is_integer(bitmask) do
            {:ok, bitmask}
          end

          def dump(_), do: :error
        end
      else
        nil
      end

    ast =
      quote do
        @behaviour Bitmask

        Module.put_attribute(__MODULE__, :bit_values, unquote(bit_vals))

        def none() do
          %Bitmask{bitmask: 0, flags: []}
        end

        def all() do
          %Bitmask{bitmask: unquote(all_bitmask.bitmask), flags: unquote(all_bitmask.flags)}
        end

        def get_all_values() do
          @bit_values
        end

        unquote(atom_to_bitmask)

        def atom_to_bitmask(_) do
          0
        end

        def int_to_bitmask(bitmask) when is_integer(bitmask) do
          flags =
            Enum.filter(@bit_values, fn {_keyword, val} -> Bitwise.band(val, bitmask) > 0 end)
            |> Keyword.keys()

          %Bitmask{bitmask: bitmask, flags: flags}
        end

        def atom_flags_to_bitmask(atom_flags) when is_list(atom_flags) do
          bitmask =
            Keyword.take(@bit_values, atom_flags)
            |> Enum.reduce(0, fn {_flag_name, value}, acc ->
              acc + value
            end)

          %Bitmask{bitmask: bitmask, flags: atom_flags}
        end

        def has_flag(%Bitmask{bitmask: bitmask, flags: _}, flag) when is_atom(flag) do
          Bitwise.band(bitmask, atom_to_bitmask(flag)) > 0
        end

        def has_flag(bitmask, flag) when is_integer(bitmask) and is_atom(flag) do
          Bitwise.band(bitmask, atom_to_bitmask(flag)) > 0
        end

        unquote(ecto_code)
      end

    ast
  end

  @doc """
    Returns the bitmask with no flags set
      iex> MyBitmask.none()
      %Bitmask{bitmask: 0, flags: []}

  """
  @doc since: "0.3.0"
  @callback none() :: %Bitmask{bitmask: integer(), flags: list(atom())}

  @doc """
    Returns the bitmask with all flags set
      iex> MyBitmask.all()
      %Bitmask{bitmask: 15, flags: [:flag_1, :flag_2, :flag_3, :flag_4]}

  """
  @doc since: "0.3.0"
  @callback all() :: %Bitmask{bitmask: integer(), flags: list(atom())}

  @doc """
    Converts an atom from the bitmask into its underlying value
      iex> MyBitmask.atom_to_bitmask(:flag_3)
      4

  """
  @doc since: "0.1.0"
  @doc group: "Generated Functions"
  @callback atom_to_bitmask(atom()) :: integer()

  @doc """
    Converts a list of atoms into a bitmask
      iex> MyBitmask.atom_flags_to_bitmask([:flag_1, :flag_3])
      %Bitmask{bitmask: 5, flags: [:flag_1, :flag_3]}

  """
  @doc since: "0.1.0"
  @doc group: "Generated Functions"
  @callback atom_flags_to_bitmask(list(atom())) :: %Bitmask{bitmask: integer(), flags: list(atom())}

  @doc """
    Converts an integer into a bitmask
      iex> MyBitmask.int_to_bitmask(3)
      %Bitmask{bitmask: 3, flags: [:flag_1, :flag_2]}

  """
  @doc since: "0.1.0"
  @doc group: "Generated Functions"
  @callback int_to_bitmask(integer()) :: %Bitmask{bitmask: integer(), flags: list(atom())}

  @doc """
    Checks if a bitmask has a flag set
      iex> bitmask = MyBitmask.int_to_bitmask(3)
      %Bitmask{bitmask: 3, flags: [:flag_1, :flag_2]}
      iex> MyBitmask.has_flag(bitmask, :flag_2)
      true
      iex> MyBitmask.has_flag(3, :flag_2)
      true

  """
  @doc since: "0.1.0"
  @callback has_flag(%Bitmask{bitmask: integer(), flags: list(atom())} | integer(), atom()) :: boolean()

  @doc """
    Returns the a list of all the bitmasks flags
      iex> MyBitmask.get_all_values()
      [flag_1: 1, flag_2: 2, flag_3: 4, flag_4: 8]

  """
  @doc since: "0.1.0"
  @doc group: "Generated Functions"
  @callback get_all_values() :: list({atom(), integer()})
end
