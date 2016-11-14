defmodule AuthenticatorTest do

  use ExUnit.Case
  alias Simulator.Authenticator, as: Auth

  describe "Authenticator Tests" do

    setup do
      {:ok, pid } = Auth.start_link 10
      %{pid: pid}
    end

    test "True Authentications", map do
      assert Auth.authenticate map.pid, 10, 15
      assert Auth.authenticate map.pid, 10, 10
      assert Auth.authenticate map.pid, 10, 19
    end

    test "False Authentications", map do
      assert !(Auth.authenticate map.pid, 0, 11)
      assert !(Auth.authenticate map.pid, 5 , 4 )
      assert !(Auth.authenticate map.pid, 1 , 99)
    end



  end

end
