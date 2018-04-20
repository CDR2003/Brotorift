defmodule Brotorift.RanchProtocol do
  use GenServer

  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _protocolOptions) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport}])
    {:ok, pid}
  end

  def init({ref, socket, transport}) do
    IO.puts("Starting protocol")

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport}) do
    IO.inspect(data)
    transport.send(socket, data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    IO.puts("Closing")
    transport.close(socket)
    {:stop, :normal, state}
  end
end
