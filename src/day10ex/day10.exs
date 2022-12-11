defmodule Solution do
  def step({[["noop"] | t], {clock, x}}) do
    {[{clock, x}], {t, {clock + 1, x}}}
  end

  def step({[["addx", n] | t], {clock, x}}) do
    n = String.to_integer n
    {[{clock, x}, {clock + 1, x + n}], {t, {clock + 2, x + n}}}
  end

  def step({[], _}), do: nil
end

interestingCycles = MapSet.new [19, 59, 99, 139, 179, 219]

xValues =
  System.argv
  |> List.first
  |> File.read!
  |> String.trim
  |> String.split("\n")
  |> Enum.map(&String.split(&1, " "))
  |> then(fn el -> {el, {1, 1}} end)
  |> Stream.unfold(&Solution.step/1)
  |> Enum.concat

xValues
|> Enum.filter(fn {c, _} -> MapSet.member?(interestingCycles, c) end)
|> Enum.map(fn {c, x} -> (c + 1) * x end)
|> Enum.sum
|> IO.puts
