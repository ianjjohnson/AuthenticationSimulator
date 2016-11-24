defmodule StreamCipherTest do

  use ExUnit.Case
  alias Simulator.StreamCipher, as: Cipher

  describe "Cipher Tests" do

    test "Novel cipher works correctly" do
      assert Cipher.encrypt(10,5) == 100
    end

    test "Cipher updates map correctly" do
      conn = %Simulator.Connection{n: 10, key: 5}
      {delay, conn} = Cipher.update(conn)
      assert delay == 100
      assert conn.key == 5
      assert conn.n == 550
    end

  end

end
