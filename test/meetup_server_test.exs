defmodule MeetupServerTest do

  use ExUnit.Case
  alias Simulator.MeetupServer, as: Meetup

  describe "Meetup Tests" do


    test "Self not in users" do
      Meetup.register_user
      assert Enum.count(Enum.filter(Meetup.get_users, &(&1 == self))) == 0
    end

    test "Registering other used increases user count" do
      start_count = Enum.count(Meetup.get_users)
      spawn(fn -> Meetup.register_user end)
      :timer.sleep(500)
      assert Enum.count(Meetup.get_users) - start_count == 1
    end



  end

end
