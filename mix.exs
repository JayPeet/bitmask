defmodule Bitmask.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitmask,
      version: "0.4.0",
      elixir: "~> 1.11",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Bitmask",
      source_url: "https://github.com/jaypeet/bitmask",
      description: description(),
      package: package(),
      docs: [
        main: "Bitmask",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.35.0", only: :dev, runtime: false},
      {:benchee, "~> 1.3", only: :test, runtime: false},
      {:ecto, "~> 3.8", optional: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "A use macro for automatically generating a Bitmask from a collection of atoms."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jaypeet/bitmask"}
    ]
  end
end
