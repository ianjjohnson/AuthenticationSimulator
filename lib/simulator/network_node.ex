defmodule Simulator.NetworkNode do

  use GenServer


  def start_link() do
    GenServer.start __MODULE__, []
  end

  def startup(fromPid, toPid) do
    GenServer.cast fromPid, {:startup, toPid}
  end

  def setup(pid) do
    GenServer.cast pid, {:setup}
  end




  def init(_args) do
    Simulator.MeetupServer.register_user
    {:ok, Simulator.MeetupServer.get_users}
  end

  def handle_call {:message, content}, from, state do
    spawn(fn -> respond_to(Kernel.elem(from, 0), state) end)
    IO.puts "Message \"#{content}\" received"
    IO.inspect self
    {:reply, content, state}
  end

  def handle_cast {:startup, targetPid}, state do
    GenServer.call targetPid, {:message, :ping}
    {:noreply, [ %Simulator.Connection{pid: targetPid} | state]}
  end

  def handle_cast {:setup}, state do
    {:noreply,
     Simulator.MeetupServer.get_users
     |> Enum.map(&(%Simulator.Connection{pid: &1}))
    }
  end

  defp respond_to sender, state do
    conn = Enum.filter state, &(&1.pid == sender)
    IO.inspect state
    IO.puts "Respond to: #{conn}"
  end

end
