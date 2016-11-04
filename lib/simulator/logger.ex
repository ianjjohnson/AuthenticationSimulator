defmodule Simulator.Logger do

  use GenServer
  @me __MODULE__

  def start_link(fileName) do
    GenServer.start __MODULE__, fileName, name: @me
  end

  def write(binary) do
    GenServer.cast @me, {:write, binary}
  end

  #Implementation

  def init(fileName) do
    File.open fileName, [:write]
  end

  def handle_cast {:write, binary}, file do
    IO.binwrite file, binary
    {:noreply, file}
  end

end
