defmodule Simulator.NodeSupervisor do
  use Supervisor

  def start_link arg \\ [] do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do

    children = [
        #The clients on the network
        worker(Simulator.NetworkNode, [], [id: make_ref]),
        worker(Simulator.NetworkNode, [], [id: make_ref]),

        worker(Simulator.Attacker,    [], [id: make_ref])
    ]

    supervise(children, strategy: :one_for_one)

  end
end
