defmodule ExcErrorTest do
  use ExUnit.Case
  doctest ExcError

  require ExcError

  describe "error without message" do
    ExcError.define(ErrorWithNoMessage)

    test "works" do
      assert_error(ErrorWithNoMessage, "ErrorWithNoMessage")
    end
  end

  describe "error with fixed message" do
    ExcError.define(ErrorWithFixedMessage, message: "fixed error message")

    test "works" do
      assert_error(ErrorWithFixedMessage, "fixed error message")
    end
  end

  describe "error with custom message" do
    ExcError.define(ErrorWithCustomMessage)

    test "works" do
      assert_error(
        ErrorWithCustomMessage,
        [message: "custom message"],
        "custom message"
      )
    end
  end

  describe "error with custom message calllback" do
    ExcError.define ErrorWithMessageCallback do
      def message(exc), do: "custom callback message - #{exc.message}"
    end

    test "works" do
      assert_error(
        ErrorWithMessageCallback,
        [message: "custom error message"],
        "custom callback message - custom error message"
      )
    end
  end

  describe "error with several custom fields" do
    ExcError.define ErrorWithCustomFields, [:some_field, :other_field] do
      def message(exc), do: "#{exc.some_field} - #{exc.other_field}"
    end

    test "works" do
      assert_error(
        ErrorWithCustomFields,
        [some_field: "some_field_value", other_field: "other_field_value"],
        "some_field_value - other_field_value"
      )
    end
  end

  describe "error with several custom fields but without message" do
    ExcError.define(ErrorWithFieldsButNoMessage, [:some_field, :other_field])

    test "works" do
      assert_error(ErrorWithFieldsButNoMessage)
    end
  end

  describe "mixed fields with defaults and without" do
    ExcError.define(ErrorWithMixedFields, [:some_field], other_field: "other-field-value")

    test "works" do
      error = %ErrorWithMixedFields{some_field: "some-field-value"}
      assert error.other_field == "other-field-value"
    end
  end

  describe "error with custom method" do
    ExcError.define ErrorWithMethod do
      def test(), do: :test
    end

    test "works" do
      assert ErrorWithMethod.test() == :test
    end
  end

  describe "exception with fixed message but custom message callback" do
    ExcError.define ErrorWithFixedMessageAndCallback, message: "fixed message" do
      def message(exc), do: "#{exc.message} - message callback"
    end

    test "works" do
      assert_error(ErrorWithFixedMessageAndCallback, "fixed message - message callback")
    end
  end

  describe "exception in submodule" do
    defmodule SubModule do
      ExcError.define(Error)
    end

    test "works" do
      assert_error(SubModule.Error)
    end
  end

  describe "String.Chars protocl" do
    ExcError.define(PrintableError)

    test "prints exception message" do
      assert to_string(%PrintableError{message: "custom error"}) == "custom error"
    end
  end

  describe "wrap" do
    ExcError.define(ErrorWrapper)

    test "wraps error tuple" do
      exc = ErrorWrapper.wrap({:error, :some_error})

      assert exc.cause == :some_error
      assert to_string(exc) == "ErrorWrapper cause:some_error"
    end

    test "wraps arbitrary terms" do
      exc = ErrorWrapper.wrap(:some_error)

      assert exc.cause == :some_error
      assert to_string(exc) == "ErrorWrapper cause:some_error"
    end
  end

  def assert_error(exc, expected_msg \\ ~r/.*/) do
    assert_error(exc, [], expected_msg)
  end

  def assert_error(exc, options, expected_msg) do
    assert_raise exc, expected_msg, fn ->
      raise exc, options
    end
  end
end
