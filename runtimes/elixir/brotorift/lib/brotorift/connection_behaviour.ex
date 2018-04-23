defmodule Brotorift.ConnectionBehaviour do
  @callback start_link({socket :: any(), transport :: module(), handler :: module()}) :: {:ok, pid()}
  @callback stop(pid :: pid()) :: any()
  @callback handle_data(pid :: pid(), data :: iodata()) :: any()
end
