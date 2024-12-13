defmodule Bitmask.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitmask,
      version: "0.3.1",
      elixir: "~> 1.10",
      deps: deps(),

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
      {:ex_doc, "~> 0.28.0", only: :dev, runtime: false},
      {:ecto, "~> 3.8", optional: true}
    ]
  end

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
