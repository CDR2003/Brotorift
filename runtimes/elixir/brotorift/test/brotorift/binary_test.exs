defmodule Brotorift.BinaryTest do
  use ExUnit.Case, async: true

  import Brotorift.Binary

  defmacro read_write(type, value) do
    quote do
      data = unquote(:"write_#{type}")(unquote(value), <<>>)
      assert {unquote(value), _} = unquote(:"read_#{type}")(data)
    end
  end

  test "write read bool" do
    read_write :bool, true
    read_write :bool, false
  end

  test "write read byte" do
    read_write :byte, 0
    read_write :byte, 255
  end

  test "write read short" do
    read_write :short, 0
    read_write :short, -1234
    read_write :short, 1234
  end

  test "write read int" do
    read_write :int, 0
    read_write :int, -123123
    read_write :int, 123123
  end

  test "write read long" do
    read_write :long, 0
    read_write :long, -123456789
    read_write :long, 123456789
  end

  test "write read float" do
    read_write :float, 0.0
    read_write :float, -1.0
    read_write :float, 2.0
  end

  test "write read double" do
    read_write :double, 0.0
    read_write :double, -1.0
    read_write :double, 2.0
  end

  test "write read string" do
    read_write :string, ""
    read_write :string, "fitbos"
  end
end
