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
    {:ok, max_wait}
  end

  def handle_cast {:attack}, max_wait do
    spawn(fn -> attack(Simulator.MeetupServer.get_users, max_wait) end)
    {:noreply, max_wait}
  end

  defp attack(users, max_wait) do

    #Send an attack message. Important: how does the sim respond?
    [a,b|_tail] = users
    Simulator.NetworkNode.check_if_vulnerable(a, b)

    :timer.sleep(:rand.uniform(max_wait))
    attack(users, max_wait)
  end

end
