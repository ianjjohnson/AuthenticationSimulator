defmodule ClockTest do

  use ExUnit.Case
  alias Simulator.Clock, as: Clock

  describe "Clock Tests" do

    test "Clock increases" do
      assert Clock.current_time <= Clock.current_time
    end

    test "Clock increases at correct rate" do
      start = Clock.current_time
      :timer.sleep(1000)
      delta = Clock.current_time - start
      assert (delta > 900 && delta < 1100)
    end

  end

end
