defmodule Simulator.Authenticator do

  use GenServer
  @me __MODULE__

  def start_link windowsize do
    GenServer.start __MODULE__, windowsize
  end

  def authenticate(pid, expected, received) do
    GenServer.call pid, {:auth, expected, received}
  end

  #Implementation
  def init(windowsize) do
    {:ok, %{windowsize: windowsize}}
  end

  def handle_call {:auth, expected, received}, _from, state do
    {:reply, (received-expected < state.windowsize) , state}
  end

end
