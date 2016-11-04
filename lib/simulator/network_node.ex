defmodule Simulator.NetworkNode do

  use GenServer

  alias Simulator.Logger

  @keyrange 255

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

  def update_connection(pid, conn) do
    GenServer.cast pid, {:update, conn}
  end




  def init(_args) do
    Simulator.MeetupServer.register_user
    {:ok, Simulator.MeetupServer.get_users}
  end

  def handle_call {:state}, _from, state do
    {:reply, state, state}
  end

  def handle_cast {:newMessage, {key, n}, from}, state do

    Logger.write("Setup received at #{inspect self} from #{inspect from} with params #{inspect {key,n}}\n")

    state =
    state
    |> Enum.map(&(set_params(&1,{key, n, from})))

    state
    |> Enum.map(&(Simulator.NetworkNode.add_to_inbox &1.pid, :gotSetup, self))

    {:noreply,state}

  end

  def handle_cast {:newMessage, content, from}, state do
    received = Simulator.Clock.current_time
    myPid = self
    spawn(fn -> respond_to(from, myPid, state, received) end)
    [conn] = Enum.filter state, &(&1.pid == from)
    Logger.log content, myPid, from, received, conn
    {:noreply, state}
  end

  def handle_cast {:startup}, state do
    state =
    state
    |> Enum.map( &( %{&1 | n: :rand.uniform(@keyrange), key: :rand.uniform(@keyrange)}))


    state
    |> Enum.map(&(Simulator.NetworkNode.add_to_inbox &1.pid, {&1.key, &1.n}, self))

    {:noreply, state}
  end

  def handle_cast {:setup}, _state do
    {:noreply,
     Simulator.MeetupServer.get_users
     |> Enum.map(&(%Simulator.Connection{pid: &1}))
    }
  end

  def handle_cast {:update, conn}, state do
    state = Enum.filter state, &(&1.pid != conn.pid)
    {:noreply, [conn | state]}
  end

  defp respond_to recipient, sender, state, received do
    [conn] = Enum.filter state, &(&1.pid == recipient)
    {delay, conn} = Simulator.StreamCipher.update(conn, received)
    :timer.sleep(delay)
    Simulator.NetworkNode.add_to_inbox(recipient, :tmp, sender)
    Simulator.NetworkNode.update_connection(sender, conn)
  end

  defp set_params conn, {key, n, from} do
    if conn.pid == from do
      delay = Simulator.StreamCipher.encrypt(n, key)
      %{conn | n: delay, key: key, expected: delay, danger: delay/2}
    else
      conn
    end
  end

end
