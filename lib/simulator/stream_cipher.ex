defmodule Simulator.StreamCipher do

  use GenServer
  @me __MODULE__

  def start_link() do
    GenServer.start __MODULE__, [], name: @me
  end

  def encrypt(keystream, key) do
    GenServer.call @me, {:encrypt, keystream, key}
  end


  #Implementation
  def init(_args), do: {:ok, %{}}


  def handle_call {:encrypt, keystream, key}, _from, state do
    {:reply,
    keystream + key,
    state
    }
  end


end
