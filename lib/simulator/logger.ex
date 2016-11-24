defmodule Simulator.Logger do

  defstruct pid: 0, window: 0, truePos: 0, falsePos: 0, trueNeg: 0, falseNeg: 0

  alias Simulator.Authenticator, as: Auth

  use GenServer
  @me __MODULE__

  def start_link(logFile, timeFile, authFile, windowSizes) do
    GenServer.start __MODULE__, {logFile, timeFile, authFile, windowSizes}, name: @me
  end

  def write(binary) do
    GenServer.cast @me, {:write, binary}
  end

  def log(content, myPid, from, received, conn) do
    GenServer.cast @me, {:log, content, myPid, from, received, conn}
  end

  def log_attack(received, expected) do
    GenServer.cast @me, {:attack, received, expected}
  end

  def write_authenticators() do
    GenServer.cast @me, {:write}
  end

  #Implementation

  def init({logFile, timeFile, authFile, windowSizes}) do
    {:ok, log }   = File.open logFile,    [:write]
    {:ok, time}   = File.open timeFile,   [:write]
    {:ok,
      %{
        log: log,
        time: time,
        auth: authFile,
        authenticators: setup_authenticators(windowSizes)
        }
    }
  end

  def handle_cast {:log, content, myPid, from, received, conn}, state do

    print_to_log_file(state.log, content, myPid, from, received, conn)
    print_to_time_file(state.time, received, conn.expected)

    state = %{state | authenticators:
      state.authenticators
      |> Enum.map(&(update_authenticator(&1, content, received, conn.expected)))
    }

    {:noreply, state}
  end

  def handle_cast {:attack, received, expected}, state do

    IO.binwrite state.log, "Got attack at time #{received}\n"

    state = %{state | authenticators: update_authenticators(state, received, expected)}

    {:noreply, state}
  end


  def handle_cast {:write, binary}, state do
    IO.binwrite state.log, binary
    {:noreply, state}
  end

  def handle_cast {:write}, state do
    {:ok, file} = File.open state.auth, [:write]
    state.authenticators |> Enum.map(&(write_authenticator(&1, file)))
    {:noreply, state}
  end

  #Write the contents of an authenticator to the auth log file
  defp write_authenticator(authenticator, file) do
    IO.binwrite file, "Window: #{authenticator.window}    \n"
                   <> "\t True  Pos: #{authenticator.truePos} \n"
                   <> "\t False Pos: #{authenticator.falsePos} \n"
                   <> "\t True  Neg: #{authenticator.trueNeg} \n"
                   <> "\t False Neg: #{authenticator.falseNeg} \n"
  end

  defp update_authenticators(state, received, expected) do
    state.authenticators
    |> Enum.map(&(update_authenticator(&1, :unsafe, received, expected)))
  end

  #Update an authenticator's statistic given a new message
  defp update_authenticator(map, content, received, expected) do

    case {content, Auth.authenticate(map.pid,expected,received)} do

        {:safe  , :true } -> %{map | truePos:  map.truePos  + 1}
        {:unsafe, :true } -> %{map | falsePos: map.falsePos + 1}
        {:safe  , :false} -> %{map | falseNeg: map.falseNeg + 1}
        {:unsafe, :false} -> %{map | trueNeg:  map.trueNeg  + 1}
        _                 -> map

    end

  end

  defp setup_authenticators(windowSizes) do
    windowSizes
    |> Enum.map(&(
                %Simulator.Logger
                {
                    pid: Kernel.elem(Auth.start_link(&1), 1),
                    window: &1
                }))
  end

  #Print a message tie to the time log file
  defp print_to_time_file file, received, expected do
    IO.binwrite file, "#{received - expected}\n"
  end

  #Print a message to the verbose log file
  defp print_to_log_file file, content, myPid, from, received, conn do
    IO.binwrite file, "Message \"#{content}\" \n"
                  <>  "\tReceived at PID: #{inspect myPid}, from PID: #{inspect from}\n"
                  <>  "\tReceived at time: #{received}, expected: #{conn.expected}\n"
                  <>  "\tConnection: #{inspect conn}\n"
  end

end
