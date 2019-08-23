defmodule TypespecsTest do
  require ExcError

  ExcError.define(ErrorWithoutCustomFields)
  @type error_without_custom_fields :: ErrorWithoutCustomFields.t()

  ExcError.define ErrorWithCustomFields, [:custom_field] do
    @type t :: %__MODULE__{
            custom_field: term
          }
  end

  @type error_with_custom_fields :: ErrorWithCustomFields.t()
end
