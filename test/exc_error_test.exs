defmodule ExcErrorTest do
  use ExUnit.Case
  doctest ExcError

  require ExcError
  require Helpers

  describe "exception without message" do
    @exc Helpers.random_struct()

    ExcError.define(@exc)

    test "works" do
      assert_error(@exc, to_string(@exc))
    end
  end

  describe "exception with fixed message" do
    @exc Helpers.random_struct()

    ExcError.define(@exc, message: "fixed error message")

    test "works" do
      assert_error(@exc, "fixed error message")
    end
  end

  describe "exception with custom message" do
    @exc Helpers.random_struct()

    ExcError.define(@exc)

    test "works" do
      assert_error(
        @exc,
        [message: "custom message"],
        "custom message"
      )
    end
  end

  describe "exception with custom message calllback" do
    @exc Helpers.random_struct()

    ExcError.define @exc do
      def message(exc), do: "custom callback message - #{exc.message}"
    end

    test "works" do
      assert_error(
        @exc,
        [message: "custom error message"],
        "custom callback message - custom error message"
      )
    end
  end

  describe "exception with several custom fields" do
    @exc Helpers.random_struct()

    ExcError.define @exc, [:some_field, :other_field] do
      def message(exc), do: "#{exc.some_field} - #{exc.other_field}"
    end

    test "works" do
      assert_error(
        @exc,
        [some_field: "some_field_value", other_field: "other_field_value"],
        "some_field_value - other_field_value"
      )
    end
  end

  describe "exception with several custom fields but with default message" do
    @exc Helpers.random_struct()

    ExcError.define(@exc, [:some_field, :other_field])

    test "works" do
      assert_error(@exc)
    end
  end

  describe "exception with custom method" do
    @exc Helpers.random_struct()

    ExcError.define @exc do
      def test(), do: :test
    end

    test "works" do
      assert @exc.test == :test
    end
  end

  describe "exception with default message but custom message callback" do
    @exc Helpers.random_struct()

    ExcError.define @exc, message: "fixed message" do
      def message(exc), do: "#{exc.message} - message callback"
    end

    test "works" do
      assert_error(@exc, "fixed message - message callback")
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
