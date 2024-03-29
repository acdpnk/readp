defmodule Readp.Mixfile do
  use Mix.Project

  def project do
    [ app: :readp,
      version: "0.0.1",
      elixir: "~> 0.10.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ {:jsex, github: "talentdeficit/jsex"},
      {:parallel, github: "eproxus/parallel"} ]
  end
end
