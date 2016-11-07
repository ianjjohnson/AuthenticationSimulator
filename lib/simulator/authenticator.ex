defmodule Simulator.Authenticator do

  use GenServer
  @me __MODULE__

  def start_link window do
    GenServer.start __MODULE__, window, name: @me
  end

  def authenticate(connection, received) do
    GenServer.call @me, {:auth, connection, received}
  end

  #Implementation
  def init(window) do
    {:ok, %{windowsize: window }}
  end

  def handle_call {:auth, connection, received}, _from, state do
    {:reply, (received-connection.expected < state.windowsize) , state}
  end

end
