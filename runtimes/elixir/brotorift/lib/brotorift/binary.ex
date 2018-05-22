defmodule Brotorift.Binary do

  # Read

  def read_bool(data) do
    <<value::8-little-unsigned, data::binary>> = data
    {data, value != 0}
  end

  def read_byte(data) do
    <<value::8-little-unsigned, data::binary>> = data
    {data, value}
  end

  def read_short(data) do
    <<value::16-little-signed, data::binary>> = data
    {data, value}
  end

  def read_int(data) do
    <<value::32-little-signed, data::binary>> = data
    {data, value}
  end

  def read_long(data) do
    <<value::64-little-signed, data::binary>> = data
    {data, value}
  end

  def read_ushort(data) do
    <<value::16-little-unsigned, data::binary>> = data
    {data, value}
  end

  def read_uint(data) do
    <<value::32-little-unsigned, data::binary>> = data
    {data, value}
  end

  def read_ulong(data) do
    <<value::64-little-unsigned, data::binary>> = data
    {data, value}
  end

  def read_float(data) do
    <<value::32-little-float, data::binary>> = data
    {data, value}
  end

  def read_double(data) do
    <<value::64-little-float, data::binary>> = data
    {data, value}
  end

  def read_string(data) do
    <<len::32-little, data::binary>> = data
    <<value::binary-size(len), data::binary>> = data
    {data, value}
  end
  
  def read_datetime(data) do
    {data, timestamp} = read_int(data)
    {:ok, datetime} = DateTime.from_unix(timestamp)
    {data, datetime}
  end

  def read_byte_buffer(data) do
    <<len::32-little, value::binary-size(len), data::binary>> = data
    {data, value}
  end

  def read_list(data, reader) do
    <<len::32-little, data::binary>> = data
    {data, values} = read_list_iter(data, reader, [], len)
    {data, Enum.reverse(values)}
  end

  defp read_list_iter(data, _reader, values, 0) do
    {data, values}
  end
  defp read_list_iter(data, reader, values, current) do
    {data, value} = reader.(data)
    values = [value | values]
    read_list_iter(data, reader, values, current - 1)
  end

  def read_set(data, reader) do
    {data, list} = read_list(data, reader)
    {data, MapSet.new(list)}
  end

  def read_map(data, key_reader, value_reader) do
    <<len::32-little, data::binary>> = data
    read_map_iter(data, key_reader, value_reader, %{}, len)
  end

  defp read_map_iter(data, _key_reader, _value_reader, values, 0) do
    {data, values}
  end
  defp read_map_iter(data, key_reader, value_reader, values, current) do
    {data, key} = key_reader.(data)
    {data, value} = value_reader.(data)
    values = Map.put(values, key, value)
    read_map_iter(data, key_reader, value_reader, values, current - 1)
  end

  def read_vector2(data) do
    {data, x} = read_float(data)
    {data, y} = read_float(data)
    {data, {x, y}}
  end

  def read_vector3(data) do
    {data, x} = read_float(data)
    {data, y} = read_float(data)
    {data, z} = read_float(data)
    {data, {x, y, z}}
  end

  def read_color(data) do
    {data, r} = read_float(data)
    {data, g} = read_float(data)
    {data, b} = read_float(data)
    {data, a} = read_float(data)
    {data, {r, g, b, a}}
  end

  # Write

  def write_bool(data, value) do
    bool_data = if value do 1 else 0 end
    <<data::binary, bool_data::8-little-unsigned>>
  end

  def write_byte(data, value) do
    <<data::binary, value::8-little-unsigned>>
  end

  def write_short(data, value) do
    <<data::binary, value::16-little-signed>>
  end

  def write_int(data, value) do
    <<data::binary, value::32-little-signed>>
  end

  def write_long(data, value) do
    <<data::binary, value::64-little-signed>>
  end

  def write_ushort(data, value) do
    <<data::binary, value::16-little-unsigned>>
  end

  def write_uint(data, value) do
    <<data::binary, value::32-little-unsigned>>
  end

  def write_ulong(data, value) do
    <<data::binary, value::64-little-unsigned>>
  end

  def write_float(data, value) do
    <<data::binary, value::32-little-float>>
  end

  def write_double(data, value) do
    <<data::binary, value::64-little-float>>
  end

  def write_string(data, value) do
    <<data::binary, String.length(value)::32-little, value::binary>>
  end
  
  def write_datetime(data, value) do
    timestamp = DateTime.to_unix(value)
    write_int(data, timestamp)
  end

  def write_byte_buffer(data, value) do
    <<data::binary, byte_size(value)::32-little, value::binary>>
  end

  def write_list(data, value, writer) do
    data = <<data::binary, length(value)::32-little>>
    write_list_iter(data, writer, value)
  end

  defp write_list_iter(data, _writer, []) do
    data
  end
  defp write_list_iter(data, writer, [x | xs]) do
    data = writer.(data, x)
    write_list_iter(data, writer, xs)
  end

  def write_set(data, value, writer) do
    write_list(data, MapSet.to_list(value), writer)
  end

  def write_map(data, value, key_writer, value_writer) do
    data = <<data::binary, map_size(value)::32-little>>
    write_map_iter(data, key_writer, value_writer, Map.to_list(value))
  end

  defp write_map_iter(data, _key_writer, _value_writer, []) do
    data
  end
  defp write_map_iter(data, key_writer, value_writer, [{key, value} | xs]) do
    data = key_writer.(data, key)
    data = value_writer.(data, value)
    write_map_iter(data, key_writer, value_writer, xs)
  end

  def write_vector2(data, {x, y}) do
    data = write_float(data, x)
    data = write_float(data, y)
    data
  end

  def write_vector3(data, {x, y, z}) do
    data = write_float(data, x)
    data = write_float(data, y)
    data = write_float(data, z)
    data
  end

  def write_color(data, {r, g, b, a}) do
    data = write_float(data, r)
    data = write_float(data, g)
    data = write_float(data, b)
    data = write_float(data, a)
    data
  end
end
