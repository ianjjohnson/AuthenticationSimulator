defmodule Simulator.NodeSupervisor do
  use Supervisor

  def start_link arg \\ [] do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do

    children = [
        #The actual game server
        #worker(Simulator.NetworkNode, [])
    ]

    supervise(children, strategy: :one_for_one)

  end
end
