defmodule Simulator.Attacker do

  use GenServer
  @me __MODULE__

  def start_link args \\ [100] do
    GenServer.start __MODULE__, args, name: @me
  end

  def start_attack do
    GenServer.cast @me, {:attack}
  end


  #Implementation

  def init([max_wait | _tail]) do
    Simulator.MeetupServer.register_user
    {:ok, max_wait}
  end

  def handle_cast {:attack}, max_wait do
    spawn(fn -> attack(Simulator.MeetupServer.get_users, max_wait, self) end)
    {:ok, max_wait}
  end

  defp attack(users, max_wait, pid) do

    #Send an attack message. Important: how does the sim respond?

    :thread.sleep(:uniform.rand(max_wait))
    attack(users, max_wait, pid)
  end

end
