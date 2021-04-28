defmodule ExcError do
  @default_fields [:cause]

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

  defmacro define(name, options \\ []) do
    record_fields = prepare_record_fields(options) ++ @default_fields

    quote location: :keep do
      defmodule unquote(name) do
        defexception(unquote(record_fields))

        unquote do
          unless type_defined?(options[:do]) do
            quote do
              @type t :: %__MODULE__{
                      unquote_splicing(field_types(record_fields))
                    }
            end
          end
        end

        import unquote(__MODULE__).Helpers

        def wrap(_cause, options \\ [])

        def wrap({:error, error}, options),
          do: wrap(error, options)

        def wrap(%ErlangError{original: error}, options),
          do: wrap(error, options)

        def wrap(cause, options), do: struct(__MODULE__, Keyword.put(options, :cause, cause))

        defoverridable wrap: 1, wrap: 2

        @impl Exception
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

  def default_message(exc) do
    default_name = exc.__struct__ |> to_string() |> String.split(".") |> List.last()
    msg = Map.get(exc, :message) || default_name

    if exc.cause do
      "#{msg}; cause: #{Helpers.to_s(exc.cause)}"
    else
      msg
    end
  end

  defp prepare_record_fields(options) do
    fields = options |> Enum.reject(&match?({:do, _}, &1))
    if Enum.empty?(fields), do: [:message], else: fields
  end

  @term_type {:term, [], Elixir}

  defp field_types(fields) do
    Enum.map(fields, fn
      {key, _} -> {key, @term_type}
      key -> {key, @term_type}
    end)
  end

  defp type_defined?(nil), do: false

  defp type_defined?({:__block__, _, children}) when is_list(children),
    do: Enum.any?(children, &struct_typespec?/1)

  defp type_defined?(expr), do: struct_typespec?(expr)

  defp struct_typespec?({:@, _, [{:type, _, [{:"::", _, [{:t, _, _} | _]}]}]}), do: true
  defp struct_typespec?(_), do: false
end
