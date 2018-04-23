defmodule Brotorift.Binary do
  def read_bool(data) do
    <<value::8-little-unsigned, data::binary>> = data
    {value != 0, data}
  end

  def read_byte(data) do
    <<value::8-little-unsigned, data::binary>> = data
    {value, data}
  end

  def read_short(data) do
    <<value::16-little-signed, data::binary>> = data
    {value, data}
  end

  def read_int(data) do
    <<value::32-little-signed, data::binary>> = data
    {value, data}
  end

  def read_long(data) do
    <<value::64-little-signed, data::binary>> = data
    {value, data}
  end

  def read_float(data) do
    <<value::32-little-float, data::binary>> = data
    {value, data}
  end

  def read_double(data) do
    <<value::64-little-float, data::binary>> = data
    {value, data}
  end

  def read_string(data) do
    <<len::32-little, data::binary>> = data
    <<str::binary-size(len), data::binary>> = data
    {str, data}
  end

  def write_bool(value, data) do
    bool_data = if value do 1 else 0 end
    <<data::binary, bool_data::8-little-unsigned>>
  end

  def write_byte(value, data) do
    <<data::binary, value::8-little-unsigned>>
  end

  def write_short(value, data) do
    <<data::binary, value::16-little-signed>>
  end

  def write_int(value, data) do
    <<data::binary, value::32-little-signed>>
  end

  def write_long(value, data) do
    <<data::binary, value::64-little-signed>>
  end

  def write_float(value, data) do
    <<data::binary, value::32-little-float>>
  end

  def write_double(value, data) do
    <<data::binary, value::64-little-float>>
  end

  def write_string(str, data) do
    <<data::binary, String.length(str)::32-little, str::binary>>
  end
end
