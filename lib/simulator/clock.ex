defmodule Simulator.Clock do

  use GenServer
  @me __MODULE__

  def start_link() do
    GenServer.start __MODULE__, [], name: @me
  end

  def current_time() do
    GenServer.call @me, {:time}
  end


  def init(_args) do
    {:ok, :os.system_time(:milli_seconds)}
  end

  def handle_call {:time}, _from, state do
    {:reply, :os.system_time(:milli_seconds) - state, state}
  end

end
