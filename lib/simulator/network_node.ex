defmodule Simulator.NetworkNode do

  use GenServer

  alias Simulator.Logger


  def start_link() do
    GenServer.start __MODULE__, []
  end

  def startup(pid) do
    GenServer.cast pid, {:startup}
  end

  def setup(pid) do
    GenServer.cast pid, {:setup}
  end

  def get_state(pid) do
    GenServer.call pid, {:state}
  end

  def add_to_inbox(pid, message, sender) do
    GenServer.cast pid, {:newMessage, message, sender}
  end




  def init(_args) do
    Simulator.MeetupServer.register_user
    {:ok, Simulator.MeetupServer.get_users}
  end

  def handle_call {:state}, _from, state do
    {:reply, state, state}
  end

  def handle_cast {:newMessage, content, from}, state do
    myPid = self
    spawn(fn -> respond_to(from, myPid, state) end)
    Logger.write "Message \"#{content}\" received at: #{inspect myPid}, from: #{inspect from}\n"
    {:noreply, state}
  end

  def handle_cast {:startup}, state do
    state
    |> Enum.map(&(Simulator.NetworkNode.add_to_inbox &1.pid, :hello, self))

    {:noreply, state}
  end

  def handle_cast {:setup}, _state do
    {:noreply,
     Simulator.MeetupServer.get_users
     |> Enum.map(&(%Simulator.Connection{pid: &1}))
    }
  end

  defp respond_to recipient, sender, state do
    [conn] = Enum.filter state, &(&1.pid == recipient)
    :timer.sleep(1000)
    Simulator.NetworkNode.add_to_inbox(recipient, :tmp, sender)
  end

end
