defmodule Brotorift do
  use Application

  def start(_type, _args) do
    Brotorift.Supervisor.start_link([port: 9000, mod: ChatProtocol.Connection, handler: ChatProtocol.Handler])
  end
end
