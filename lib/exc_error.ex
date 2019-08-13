defmodule ExcError do
  @default_fields [:cause]

  defmacro define(name, options \\ []) do
    record_fields = prepare_record_fields(options) ++ @default_fields
    name = Macro.expand_once(name, __CALLER__)

    quote location: :keep do
      defmodule unquote(name) do
        defexception(unquote(record_fields))

        import unquote(__MODULE__).Helpers

        def wrap({:error, error}), do: %__MODULE__{cause: error}
        def wrap(cause), do: %__MODULE__{cause: cause}
        defoverridable wrap: 1

        def message(exc), do: unquote(__MODULE__).default_message(exc)
        defoverridable message: 1

        unquote(Keyword.get(options, :do, :nop))

        defimpl String.Chars do
          def to_string(exc), do: unquote(name).message(exc)
        end
      end
    end
  end

  defmacro define(name, fields, options) when is_list(fields) do
    options = fields ++ options

    quote do
      unquote(__MODULE__).define(unquote(name), unquote(options))
    end
  end

  defmodule Helpers do
    def to_s({:error, error}), do: to_s(error)

    def to_s(term) do
      if String.Chars.impl_for(term) do
        to_string(term)
      else
        inspect(term)
      end
    end
  end

  defp prepare_record_fields(options) do
    fields = options |> Enum.reject(&match?({:do, _}, &1))
    if Enum.empty?(fields), do: [:message], else: fields
  end

  def default_message(exc) do
    default_name = exc.__struct__ |> to_string() |> String.split(".") |> List.last()
    msg = Map.get(exc, :message) || default_name

    if exc.cause do
      "#{msg} cause:#{Helpers.to_s(exc.cause)}"
    else
      msg
    end
  end
end
