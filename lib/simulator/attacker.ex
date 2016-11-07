defmodule Simulator.Attacker do

  use GenServer
  @me __MODULE__

  def start_link args \\ [100] do
    GenServer.start __MODULE__, args, name: @me
  end


  #Implementation

  def init([max_wait | _tail]) do
    {:ok, max_wait}
  end


end
