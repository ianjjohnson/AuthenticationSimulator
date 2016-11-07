defmodule Simulator.Logger do

  defstruct pid: 0, truepos: 0, falsepos: 0, trueneg: 0, falseneg: 0

  use GenServer
  @me __MODULE__

  def start_link(logFile, timeFile, windowSizes) do
    GenServer.start __MODULE__, {logFile, timeFile,windowSizes}, name: @me
  end

  def write(binary) do
    GenServer.cast @me, {:write, binary}
  end

  def log(content, myPid, from, received, conn) do
    GenServer.cast @me, {:log, content, myPid, from, received, conn}
  end

  #Implementation

  def init({logFile, timeFile, windowSizes}) do
    {:ok, log } = File.open logFile,  [:write]
    {:ok, time} = File.open timeFile, [:write]
    {:ok,
      %{
        log: log,
        time: time,
        authenticators: windowSizes
                        |> Enum.map(&(Simulator.Authenticator.start_link(&1)))
                        |> Enum.map(&(%Simulator.Logger{pid: &1}))
        }
    }
  end

  def handle_cast {:log, content, myPid, from, received, conn}, state do
    print_to_log_file(state.log, content, myPid, from, received, conn)
    print_to_time_file(state.time, received, conn.expected)



    {:noreply, state}
  end

  def handle_cast {:write, binary}, files do
    IO.binwrite files.log, binary
    {:noreply, files}
  end

  defp print_to_time_file file, received, expected do
    IO.binwrite file, "#{received - expected}\n"
  end

  defp print_to_log_file file, content, myPid, from, received, conn do
    IO.binwrite file, "Message \"#{content}\" \n"
                  <>  "\tReceived at PID: #{inspect myPid}, from PID: #{inspect from}\n"
                  <>  "\tReceived at time: #{received}, expected: #{conn.expected}\n"
                  <>  "\tConnection: #{inspect conn}\n"
  end

end
