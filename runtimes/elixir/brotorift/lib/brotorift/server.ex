defmodule Brotorift.Server do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def init(args) do
    port = Keyword.fetch!(args, :port)
    mod = Keyword.fetch!(args, :mod)
    handler = Keyword.fetch!(args, :handler)
    handler.start()
    {:ok, pid} = :ranch.start_listener(__MODULE__, 500, :ranch_tcp, [{:port, port}], Brotorift.RanchProtocol, {mod, handler})
    :ranch.set_max_connections(__MODULE__, :infinity)
    {:ok, pid}
  end

  def terminate(_reason, ranch_server) do
    :ok = :ranch.stop_listener(ranch_server)
  end
end
