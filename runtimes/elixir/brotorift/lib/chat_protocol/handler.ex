defmodule ChatProtocol.Handler do
  @behaviour ChatProtocol.Behaviour

  def request_login(info) do
    IO.puts "Login: " <> info.username
  end

  def request_register(info) do
    IO.puts "Register: " <> info.username
  end
end
