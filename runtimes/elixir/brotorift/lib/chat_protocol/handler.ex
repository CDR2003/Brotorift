defmodule TestBrotorift.ChatServerHandler do
  @behaviour TestBrotorift.ChatServerBehaviour

  def start() do
    :ok
  end

  def open_connection(_connection) do
    {:ok, "fucker"}
  end

  def close_connection(_connection, _state) do
    :ok
  end

  def request_login(connection, state, info) do
    IO.puts "Login: " <> info.username <> ", " <> info.password
    :ok = TestBrotorift.ChatServerConnection.respond_login(connection, :succeeded)
    {:ok, state}
  end

  def request_register(_connection, state, info) do
    IO.puts "Register: " <> info.username
    {:ok, state}
  end
end
