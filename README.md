# ExcError

A common way to represent errors in elixir is to return tuples of format `{:error, term}`.
However `term` is often a simple atom (or another tuple with simple atom).
I believe that a better way to represent errors is to use elixir Structs.

They bring some advantages:

* Structure of the error is enforced by compiler
* It is easier to deal with additional error context (Structs have fields)
* Structs can implement protocols
* Specifically: Structs can implement `String.Chars` protocol - a nice way to get a friendly formatted error message
* Structs can implement behaviours
* Specifically: Structs can implement `Exception` behaviour. Client code can just raise error Struct as exception if it deems it sensible

This library is a thin wrapper to reduce boilerplate for defining Error structs that implement `String.Chars` protocol and `Exception` behaviour.

**Feel free to use this "Structs as Errors" pattern but please do not use this Library.
You do not need any libs to use some architectural pattern.
I have made this library to get rid of annoying duplication in internal company projects.
I recommend you to tinker your own version tailored to your specific needs. 
**

However some usage examples:

```elixir
# Basic Usage

module SomeModule do
  require ExcError

  ExcError.define(SomeError)

  def some_method
    {:error, %SomeError{}}
  end
end

{:error, %SomeError{} = my_error} = SomeModule.some_method()

# You can format error as string
to_string(my_error)

some_text = "error #{my_error}"

# You can raise error as exception
raise my_error

# default type for struct is declared for you
@spec some_function() :: :ok | {:error, SomeError.t()}

# You can define some custom fields for your struct (just like in defstruct)

ExcError.define SomeError, :some_field, other_field: "default_value"

def my_method
  {:error, %SomeError{some_field: "some-field-value"}}
end

# You can define methods for your struct

ExcError.define SomeError do
  def some_method do
    :ok
  end
end

:ok = SomeError.some_method()

# You can define custom implementation for `String.Chars` protocol

ExcError.define HttpError, [:method, :url, :code] do
  def message(exc), do: "HTTP error method:#{method} url:#{url} code:#{code}"
end

# If no custom fields are provided for your struct, ExcError defines :message field by default:

ExcError.define SomeError

"some message" = to_string(%SomeError{message: "some message"})

# You can define custom type for your struct

ExcError.define SomeError, [:custom_field] do
    @type t :: %__MODULE__{
            custom_field: atom
          }
end

# All defined structs have :cause field by default
# Use it to wrap other errors

ExcError.define SomeError

error_struct = SomeError.wrap({:error, :other_error})
:other_error = error_struct.cause

error_struct = SomeError.wrap(%SomeStruct{})
%SomeStruct{} = error_struct.cause

ExcError.define SomeOtherError, [:some_field]

error_struct = SomeOtherError.wrap({:error, :other_error}, some_field: "some-value")
:other_error = error_struct.cause
"some-value" = error_struct.some_field

```




