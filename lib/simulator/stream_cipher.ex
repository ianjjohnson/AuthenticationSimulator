defmodule Simulator.StreamCipher do

  use GenServer
  @me __MODULE__

  @maxdelay 1024

  def start_link() do
    GenServer.start __MODULE__, [], name: @me
  end

  def update(map, received) do
    GenServer.call @me, {:update, map, received}
  end


  #Implementation
  def init(_args), do: {:ok, %{}}

  def handle_call {:update, map, received}, _from, state do
    delay = encrypt(map.n, map.key)
    nextDelay = encrypt(delay, map.key)
    { :reply,
      {delay, %{map | n: nextDelay, expected: delay+nextDelay, danger: received+delay+nextDelay/2}},
      state
    }
  end

  def encrypt keystream, key do
    rem(key * keystream + 1, @maxdelay)
  end


end
