defmodule TypespecsTests do
  require ExcError

  ExcError.define(ErrorWithoutCustomFields)
  @type error_without_custom_fields :: ErrorWithoutCustomFields.t()

  ExcError.define(ErrorWithCustomFields, [:custom_field])
  @type error_with_custom_fields :: ErrorWithCustomFields.t()

  ExcError.define ErrorWithCustomType, [:custom_field] do
    @type t :: %__MODULE__{
            custom_field: term
          }
  end

  @type error_with_custom_type :: ErrorWithCustomType.t()

  ExcError.define ErrorWithOtherType, [:custom_field] do
    @type other_type :: term
  end

  @type error_with_other_type :: ErrorWithOtherType.t() | ErrorWithOtherType.other_type()

  ExcError.define ErrorWithCustomTypeAndBlock, [:custom_field] do
    def some_func do
      :ok
    end

    @type t :: %__MODULE__{
            custom_field: term
          }

    def some_other_func do
      :ok
    end
  end

  @type error_with_custom_type_and_block :: ErrorWithCustomTypeAndBlock.t()

  def type_test do
    error_fun(%ErrorWithCustomFields{custom_field: "custom-value"})
  end

  @spec error_fun(ErrorWithCustomFields.t()) :: :ok
  def error_fun(error) do
    %ErrorWithCustomFields{} = error

    :ok
  end
end
