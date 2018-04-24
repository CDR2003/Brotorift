defmodule TestBrotorift.Enums do
  def read_login_result(data) do
    <<value::32-little, data::binary>> = data
    case value do
      0 -> {data, :succeeded}
      1 -> {data, :invalid_username}
      2 -> {data, :invalid_password}
      _ -> :error
    end
  end

  def write_login_result(data, value) do
    case value do
      :succeeded -> <<data::binary, 0::32-little>>
      :invalid_username -> <<data::binary, 1::32-little>>
      :invalid_password -> <<data::binary, 2::32-little>>
      _ -> :error
    end
  end

  def read_register_result(data) do
    <<value::32-little, data::binary>> = data
    case value do
      0 -> {data, :succeeded}
      1 -> {data, :duplicate_username}
      _ -> :error
    end
  end

  def write_register_result(data, value) do
    case value do
      :succeeded -> <<data::binary, 0::32-little>>
      :duplicate_username -> <<data::binary, 1::32-little>>
      _ -> :error
    end
  end
end


defmodule TestBrotorift.UserInfo do
  defstruct [:username, :password]

  @typedoc """
  用户信息
  `:username`: 用户名
  `:password`: 密码
  """
  @type t :: %TestBrotorift.UserInfo{username: String.t(), password: String.t()}

  def read(data) do
    {data, username} = Brotorift.Binary.read_string(data)
    {data, password} = Brotorift.Binary.read_string(data)
    {data, %{username: username, password: password}}
  end

  def write(data, value) do
    data = Brotorift.Binary.write_string(data, value.username)
    data = Brotorift.Binary.write_string(data, value.password)
    data
  end
end


defmodule TestBrotorift.ChatServerConnection do
  use GenServer, restart: :temporary

  import TestBrotorift.Enums

  @behaviour Brotorift.ConnectionBehaviour

  @header_request_login 1001
  @header_request_register 1002

  @header_respond_login 2001
  @header_respond_register 2002

  @doc """
  回复登录请求

  ## Parameters

    - `connection`: ChatServerConnection Pid
    - `result`: 登录结果

  """
  @spec respond_login(connection :: pid(), result :: :succeeded | :invalid_username | :invalid_password) :: :ok
  def respond_login(connection, result) do
    GenServer.cast(connection, {:respond_login, result})
  end

  @doc """
  回复注册请求

  ## Parameters

    - `connection`: ChatServerConnection Pid
    - `result`: 注册结果

  """
  @spec respond_register(connection :: pid(), result :: :succeeded | :duplicate_username) :: :ok
  def respond_register(connection, result) do
    GenServer.cast(connection, {:respond_register, result})
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
    {:ok, state} = handler.open_connection(self())
    {:ok, {socket, transport, handler, state}}
  end

  def handle_cast({:handle_data, data}, {socket, transport, handler, state}) do
    {:ok, new_state} = process_packet(data, handler, state)
    {:noreply, {socket, transport, handler, new_state}}
  end

  def handle_cast({:respond_login, result}, {socket, transport, handler, state}) do
    data = <<@header_respond_login::32-little>>
    data = write_login_result(data, result)
    data = <<byte_size(data)::32-little, data::binary>>
    transport.send(socket, data)
    {:noreply, {socket, transport, handler, state}}
  end

  def handle_cast({:respond_register, result}, {socket, transport, handler, state}) do
    data = <<@header_respond_register::32-little>>
    data = write_register_result(data, result)
    data = <<byte_size(data)::32-little, data::binary>>
    transport.send(socket, data)
    {:noreply, {socket, transport, handler, state}}
  end

  def terminate(_reason, {_socket, _transport, handler, state}) do
    handler.close_connection(self(), state)
  end

  defp process_packet(<<>>, _handler, state) do
    {:ok, state}
  end
  defp process_packet(data, handler, state) do
    <<_size::32-little, header::32-little, data::binary>> = data
    case header do
      @header_request_login ->
        {data, info} = TestBrotorift.UserInfo.read(data)
        handler.request_login(self(), state, info)
        process_packet(data, handler, state)
      @header_request_register ->
        {data, info} = TestBrotorift.UserInfo.read(data)
        handler.request_register(self(), state, info)
        process_packet(data, handler, state)
    end
  end
end


defmodule TestBrotorift.ChatServerBehaviour do

  @doc """
  Calls when a new client connects

  ## Parameters

    - `connection`: The ChatServerConnection Pid for the client

  ## Returns

    {:ok, state}

  """
  @callback open_connection(connection :: pid()) :: {:ok, any()}

  @doc """
  Calls when a client disconnects

  ## Parameters

    - `connection`: The ChatServerConnection Pid for the client
    - `state`: The state for the connection

  """
  @callback close_connection(connection :: pid(), state :: any()) :: :ok


  @doc """
  请求登录

  ## Parameters

    - `connection`: The ChatServerConnection Pid for the client
    - `state`: The state for the connection
    - `info`: 登录时填写的用户信息

  """
  @callback request_login(connection :: pid(), state :: any(), info :: TestBrotorift.UserInfo.t) :: {:ok, any()}

  @doc """
  请求注册

  ## Parameters

    - `connection`: The ChatServerConnection Pid for the client
    - `state`: The state for the connection
    - `info`: 注册时填写的用户信息

  """
  @callback request_register(connection :: pid(), state :: any(), info :: TestBrotorift.UserInfo.t) :: {:ok, any()}

end


