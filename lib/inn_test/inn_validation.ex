defmodule InnTest.InnValidation do
  def validate(inn) when is_binary(inn) do
    case String.length(inn) do
      10 -> inn |> to_ints() |> validate_ten()
      12 -> inn |> to_ints() |> validate_twelve()
      _  -> false
    end
  end
  def validate(_inn), do: false

  @ten_coeffs [2, 4, 10, 3, 5, 9, 4, 6, 8, 0]

  defp validate_ten(inn) when length(inn) == 10 do
    last = List.last(inn)
    case Enum.zip(inn, @ten_coeffs)
      |> Enum.reduce(0, fn {a, b}, acc -> acc + a * b end)
      |> rem(11) do

      x when x > 9 ->
        rem(x, 10) == last
      x ->
        x == last
    end
  end

  @twelve_first_coeffs  [7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0]
  @twelve_second_coeffs [3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0]

  defp validate_twelve(inn) when length(inn) == 12 do
    eleventh = Enum.at(inn, 10)
    twelfth  = Enum.at(inn, 11)
    first = case Enum.take(inn, 11)
                 |> Enum.zip(@twelve_first_coeffs)
                 |> Enum.reduce(0, fn {a, b}, acc -> acc + a * b end)
                 |> rem(11) do

      x when x > 9 -> rem(x, 10)
      x -> x
    end
    second = case Enum.zip(inn, @twelve_second_coeffs)
                 |> Enum.reduce(0, fn {a, b}, acc -> acc + a * b end)
                 |> rem(11) do

      x when x > 9 -> rem(x, 10)
      x -> x
    end

    eleventh == first and twelfth == second
  end

  for num <- 0..9 do
    sym = num + 48
    defp sym_to_int(unquote(sym)), do: unquote(num)
  end

  defp to_ints(str) do
    for <<x::integer-8 <- str>>, do: sym_to_int(x)
  end
end