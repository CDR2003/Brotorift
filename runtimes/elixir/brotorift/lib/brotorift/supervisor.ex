defmodule Brotorift.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, [])
  end

  def init(args) do
    children = [
      {Brotorift.Server, args},
      {Brotorift.ConnectionSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
