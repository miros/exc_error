defmodule Helpers do
  defmacro random_struct(length \\ 20) do
    quote do
      symbols = "abcdefghijklmnopqrstuvwxyz" |> String.split("", trim: true)

      1..unquote(length)
      |> Enum.reduce([], fn _, acc -> [Enum.random(symbols) | acc] end)
      |> Enum.join("")
      |> String.capitalize()
      |> String.to_atom()
    end
  end
end
