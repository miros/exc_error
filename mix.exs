defmodule ExcError.MixProject do
  use Mix.Project

  def project do
    [
      app: :exc_error,
      version: "0.0.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
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
    [test: ["dialyzer --quiet", "test"]]
  end

  defp deps do
    [{:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}]
  end
end
