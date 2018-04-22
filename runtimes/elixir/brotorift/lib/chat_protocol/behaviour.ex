defmodule ChatProtocol.UserInfo do
  defstruct [:username, :password]
end

defmodule ChatProtocol.Connection do
end

defmodule ChatProtocol.Behaviour do
  @callback request_login(info :: UserInfo) :: any
  @callback request_register(info :: UserInfo) :: any
end
