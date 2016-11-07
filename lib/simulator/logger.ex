defmodule Simulator.Logger do

  use GenServer
  @me __MODULE__

  def start_link(logFile, timeFile) do
    GenServer.start __MODULE__, {logFile, timeFile}, name: @me
  end

  def write(binary) do
    GenServer.cast @me, {:write, binary}
  end

  def log(content, myPid, from, received, conn, auth) do
    GenServer.cast @me, {:log, content, myPid, from, received, conn, auth}
  end

  #Implementation

  def init({logFile, timeFile}) do
    {:ok, log } = File.open logFile,  [:write]
    {:ok, time} = File.open timeFile, [:write]
    {:ok, %{log: log, time: time}}
  end

  def handle_cast {:log, content, myPid, from, received, conn, auth}, files do
    IO.binwrite files.log , "Message \"#{content}\" \n"
    IO.binwrite files.log , "Messages was #{atom_to_authcode(auth)}"
    IO.binwrite files.log , "\tReceived at PID: #{inspect myPid}, from PID: #{inspect from}\n"
    IO.binwrite files.log , "\tReceived at time: #{received}, expected: #{conn.expected}\n"
    IO.binwrite files.log , "\tConnection: #{inspect conn}\n"

    IO.binwrite files.time, "#{received - conn.expected}\n"

    {:noreply, files}
  end

  def handle_cast {:write, binary}, files do
    IO.binwrite files.log, binary
    {:noreply, files}
  end

  defp atom_to_authcode(:true),  do: "Authenticated"
  defp atom_to_authcode(:false), do: "Not Authenticated"

end
