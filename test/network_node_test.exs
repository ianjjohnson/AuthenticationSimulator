defmodule NetworkNodeTest do

  use ExUnit.Case
  alias Simulator.NetworkNode, as: Node

  describe "Network Node Tests" do

    setup do
      {:ok, pid } = Node.start_link
      %{pid: pid}
    end

    test "Setup", map do
      
    end




  end

end
