defmodule Simulator.Attacker do

  use GenServer
  @me __MODULE__

  def start_link args \\ [1024] do
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

    :timer.sleep(:rand.uniform(max_wait))

    [a,b|_tail] = users

    case :rand.uniform(2) do
        1 -> Simulator.NetworkNode.check_if_vulnerable(a, b)
        2 -> Simulator.NetworkNode.check_if_vulnerable(b, a)
    end

    attack(users, max_wait)
  end

end
