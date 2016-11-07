defmodule Simulator.Authenticator do

  use GenServer
  @me __MODULE__

  def start_link windowsize do
    GenServer.start __MODULE__, windowsize
  end

  def authenticate(pid, connection, received) do
    GenServer.call pid, {:auth, connection, received}
  end

  #Implementation
  def init(windowsize) do
    {:ok, %{windowsize: windowsize}}
  end

  def handle_call {:auth, connection, received}, _from, state do
    {:reply, (received-connection.expected < state.windowsize) , state}
  end

end
