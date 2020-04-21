defmodule ExcError.MixProject do
  use Mix.Project

  def project do
    [
      app: :exc_error,
      version: "0.0.5",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      package: package(),
      description: description()
    ]
  end

  defp elixirc_paths(env) when env in [:test], do: ["lib", "test/support", "test/typespecs"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: []
    ]
  end

  def aliases() do
    [test: ["dialyzer", "test"]]
  end

  defp package do
    [
      name: :exc_error,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Miroslav Malkin"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/miros/exc_error"
      }
    ]
  end

  defp description() do
    "Simple error struct factory for Elixir"
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
