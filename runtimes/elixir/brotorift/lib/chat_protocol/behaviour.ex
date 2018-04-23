defmodule ChatProtocol.UserInfo do
  defstruct [:username, :password]

  @type t :: %ChatProtocol.UserInfo{username: String.t, password: String.t}

  def read_from_packet(data) do
    {username, data} = Brotorift.Binary.read_string(data)
    {password, data} = Brotorift.Binary.read_string(data)
    {%{username: username, password: password}, data}
  end
end


defmodule ChatProtocol.Enums do
  def write_login_result(enum, data) do
    case enum do
      :succeeded -> {:ok, <<data::binary, 0::32-little>>}
      :invalid_username -> {:ok, <<data::binary, 1::32-little>>}
      :invalid_password -> {:ok, <<data::binary, 2::32-little>>}
      _ -> :error
    end
  end
end


defmodule ChatProtocol.Connection do
  use GenServer, restart: :temporary

  @behaviour Brotorift.ConnectionBehaviour

  @header_request_login 1001
  #@header_request_register 1002

  @header_respond_login 2001

  def respond_login(connection, login_result) do
    GenServer.cast(connection, {:respond_login, login_result})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def handle_data(pid, data) do
    GenServer.cast(pid, {:handle_data, data})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init({socket, transport, handler}) do
    IO.puts "Connection started"
    {:ok, state} = handler.open_connection(self())
    {:ok, {socket, transport, handler, state}}
  end

  def handle_cast({:handle_data, data}, {socket, transport, handler, state}) do
    {:ok, new_state} = process_packet(data, handler, state)
    {:noreply, {socket, transport, handler, new_state}}
  end

  def handle_cast({:respond_login, login_result}, {socket, transport, handler, state}) do
    data = <<@header_respond_login::32-little>>
    {:ok, data} = ChatProtocol.Enums.write_login_result(login_result, data)
    data = <<byte_size(data)::32-little, data::binary>>
    transport.send(socket, data)
    {:noreply, {socket, transport, handler, state}}
  end

  def terminate(_reason, {_socket, _transport, handler, state}) do
    IO.puts "Connection stopped: "
    handler.close_connection(self(), state)
  end

  defp process_packet(data, handler, state) do
    <<_size::32-little, header::32-little, packet_data::binary>> = data
    case header do
      @header_request_login ->
        {info, _data} = ChatProtocol.UserInfo.read_from_packet(packet_data)
        handler.request_login(self(), state, info)
    end
    {:ok, state}
  end
end

defmodule ChatProtocol.Behaviour do
  @callback open_connection(connection :: pid()) :: {:ok, any()}
  @callback close_connection(connection :: pid(), state :: any()) :: any()
  @callback request_login(connection :: pid(), state :: any(), info :: UserInfo.t) :: {:ok, any()}
  @callback request_register(connection :: pid(), state :: any(), info :: UserInfo.t) :: {:ok, any()}
end