defmodule Simulator.StreamCipher do

  use GenServer
  @me __MODULE__

  @delayrange 1024
  @mindelay   50

  def start_link() do
    GenServer.start __MODULE__, [], name: @me
  end

  def update(map) do
    GenServer.call @me, {:update, map}
  end


  #Implementation
  def init(_args), do: {:ok, %{}}

  def handle_call {:update, map}, _from, state do
    delay = encrypt(map.n, map.key)
    nextDelay = encrypt(delay, map.key)
    { :reply,
      {delay, %{map | n: nextDelay, expected: map.expected+delay+nextDelay, danger: map.expected+delay+nextDelay/2}},
      state
    }
  end

  def encrypt keystream, key do
    #Novel encryption "algorithm," for simulations
    rem(key * keystream, @delayrange) + @mindelay
  end


end
