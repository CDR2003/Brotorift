defmodule Brotorift do
  use Application

  def start(_type, args) do
    Brotorift.Supervisor.start_link(args)
  end
end
