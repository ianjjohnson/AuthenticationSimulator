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

  def check_if_vulnerable(pid, attacker) do
    GenServer.cast pid, {:vulnuerable, attacker}
  end

  #Implementation

  def init(_args) do
    Simulator.MeetupServer.register_user
    {:ok, Simulator.MeetupServer.get_users}
  end

  def handle_call {:state}, _from, state do
    {:reply, state, state}
  end

  def handle_cast {:vulnuerable, attacker}, state do
    received = Simulator.Clock.current_time
    conn = get_conn_by_pid state, attacker
    Logger.log_attack received, conn.expected
    {:noreply, state}
  end

  #This is the case that the new message was a setup message
  def handle_cast {:newMessage, {key, n, time}, from}, state do

    Logger.write("Setup received at #{inspect self} from #{inspect from} with params #{inspect {key,n}}\n")

    #Upadate state for new message
    state = state |> Enum.map(&(set_params(&1,{key, n, time, from})))

    #Send response
    state |> Enum.map(&(Simulator.NetworkNode.add_to_inbox &1.pid, :gotSetup, self))

    {:noreply,state}

  end

  #This is the case for a generic non-setup message
  def handle_cast {:newMessage, content, from}, state do

    #Respond to the message (asynchronously)
    received = Simulator.Clock.current_time
    myPid = self
    spawn(fn -> respond_to_client(from, myPid, state) end)

    #Log the message
    conn = get_conn_by_pid state, from
    Logger.log content, myPid, from, received, conn

    {:noreply, state}
  end

  def handle_cast {:startup}, state do

    time = Simulator.Clock.current_time
    state = startup_state state, time
    send_messages state, time
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

  defp send_messages state, time do
    state
    |> Enum.map(&(Simulator.NetworkNode.add_to_inbox &1.pid, {&1.key, &1.n, time}, self))
  end

  defp startup_state state, time do
    state
    |> Enum.map( &( %{&1 |
                      n:        :rand.uniform(@keyrange),
                      key:      :rand.uniform(@keyrange),
                      expected: time}))
  end

  defp respond_to_client recipient, sender, state do

    #Get the expected arrival time of this message
    conn = get_conn_by_pid state, recipient
    expected = conn.expected

    #Induce delay and update stream cipher for this conn
    {delay, conn} = Simulator.StreamCipher.update(conn)
    :timer.sleep(delay - (max(Simulator.Clock.current_time - expected,0)))

    #Respond to message and update state of sender (the person who is sending the response)
    Simulator.NetworkNode.add_to_inbox(recipient, :safe, sender)
    Simulator.NetworkNode.update_connection(sender, conn)
  end

  #Helper method for setting items in a specific map in a list of maps
  defp set_params conn, {key, n, time, from} do
    if conn.pid == from do
      delay = Simulator.StreamCipher.encrypt(n, key)
      %{conn | n: delay, key: key, expected: time+delay, danger: time+delay/2}
    else
      conn
    end
  end

  #Helper method for isolating one connection
  defp get_conn_by_pid state, pid do
    [conn] = Enum.filter state, &(&1.pid == pid)
    conn
  end

end
