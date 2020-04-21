defmodule ExcError.Assertions do
  require ExcError

  defmacro assert_exc_error({:=, _meta, [{:error, exc_error}, code]}) do
    quote location: :keep do
      assert {:error, unquote(exc_error) = error} = unquote(code)

      assert Exception.exception?(error) && String.Chars.impl_for(error),
             "#{inspect(error)} is not an ExcError"

      assert error |> to_string() |> is_binary()
    end
  end
end
