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
    {:ok, :erlang.monotonic_time}
  end

  def handle_call {:time}, _from, state do
    {:reply, round((:erlang.monotonic_time - state)/1_000_000), state}
  end

end
