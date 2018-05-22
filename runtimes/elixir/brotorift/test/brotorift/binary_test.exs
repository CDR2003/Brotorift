defmodule Brotorift.BinaryTest do
  use ExUnit.Case, async: true

  import Brotorift.Binary

  defmacro read_write(type, value) do
    quote do
      data = unquote(:"write_#{type}")(<<>>, unquote(value))
      assert {_, unquote(value)} = unquote(:"read_#{type}")(data)
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
  
  test "write read ushort" do
    read_write :ushort, 0
    read_write :ushort, 1234
  end

  test "write read uint" do
    read_write :uint, 0
    read_write :uint, 123123
  end

  test "write read ulong" do
    read_write :ulong, 0
    read_write :ulong, 123456789
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
  
  test "write read datetime" do
    datetime = DateTime.utc_now()
    read_write :datetime, datetime
  end

  test "write read byte buffer" do
    read_write :byte_buffer, <<>>
    read_write :byte_buffer, <<1, 2, 3, 255>>
  end

  test "write read list" do
    data = write_list(<<>>, [1, 2, 3], &write_int/2)
    assert {<<>>, [1, 2, 3]} = read_list(data, &read_int/1)
  end

  test "write read map set" do
    data = write_set(<<>>, MapSet.new([1, 2, 3]), &write_int/2)
    {<<>>, set} = read_set(data, &read_int/1)
    assert MapSet.to_list(set) == [1, 2, 3]
  end

  test "write read map" do
    map = %{1 => "A", 2 => "B", 3 => "C"}
    data = write_map(<<>>, map, &write_int/2, &write_string/2)
    {<<>>, new_map} = read_map(data, &read_int/1, &read_string/1)
    assert map == new_map
  end

  test "write vector2" do
    read_write :vector2, {0.0, 0.0}
    read_write :vector2, {-3.0, -4.0}
    read_write :vector2, {3.0, 4.0}
  end

  test "write vector3" do
    read_write :vector3, {0.0, 0.0, 0.0}
    read_write :vector3, {-3.0, -4.0, -5.0}
    read_write :vector3, {3.0, 4.0, 5.0}
  end

  test "write color" do
    read_write :color, {0.0, 0.0, 0.0, 0.0}
    read_write :color, {1.0, 1.0, 1.0, 1.0}
  end
end
