defmodule Simulator.Authenticator do

  use GenServer

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
    {:reply, (received-expected < state.windowsize  && received >= expected) , state}
  end

end
