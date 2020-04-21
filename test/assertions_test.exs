defmodule ExcError.AssertionsTest do
  use ExUnit.Case

  require ExcError
  import ExcError.Assertions

  ExcError.define(SomeError)

  test "it validates proper ExcError structs" do
    assert_exc_error({:error, %SomeError{}} = {:error, %SomeError{}})
  end

  ExcError.define ErrorWithWrongMessage do
    @impl true
    def message(_exc), do: raise("wrong-message")
  end

  test "it checks for erros in message callback" do
    assert_raise RuntimeError, "wrong-message", fn ->
      assert_exc_error({:error, %ErrorWithWrongMessage{}} = {:error, %ErrorWithWrongMessage{}})
    end
  end
end
