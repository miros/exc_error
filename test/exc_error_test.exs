defmodule ExcErrorTest do
  use ExUnit.Case
  doctest ExcError

  require ExcError
  require Helpers

  describe "exception without message" do
    ExcError.define(Error)

    test "works" do
      assert_error(Error, "Error")
    end
  end

  describe "exception with fixed message" do
    ExcError.define(Error2, message: "fixed error message")

    test "works" do
      assert_error(Error2, "fixed error message")
    end
  end

  describe "exception with custom message" do
    ExcError.define(Error3)

    test "works" do
      assert_error(
        Error3,
        [message: "custom message"],
        "custom message"
      )
    end
  end

  describe "exception with custom message calllback" do
    ExcError.define Error4 do
      def message(exc), do: "custom callback message - #{exc.message}"
    end

    test "works" do
      assert_error(
        Error4,
        [message: "custom error message"],
        "custom callback message - custom error message"
      )
    end
  end

  describe "exception with several custom fields" do
    ExcError.define Error5, [:some_field, :other_field] do
      def message(exc), do: "#{exc.some_field} - #{exc.other_field}"
    end

    test "works" do
      assert_error(
        Error5,
        [some_field: "some_field_value", other_field: "other_field_value"],
        "some_field_value - other_field_value"
      )
    end
  end

  describe "exception with several custom fields but with default message" do
    ExcError.define(Error6, [:some_field, :other_field])

    test "works" do
      assert_error(Error6)
    end
  end

  describe "exception with custom method" do
    ExcError.define Error7 do
      def test(), do: :test
    end

    test "works" do
      assert Error7.test() == :test
    end
  end

  describe "exception with default message but custom message callback" do
    ExcError.define Error8, message: "fixed message" do
      def message(exc), do: "#{exc.message} - message callback"
    end

    test "works" do
      assert_error(Error8, "fixed message - message callback")
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
