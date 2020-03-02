defmodule EpidemicTest do
  use ExUnit.Case
  doctest Epidemic

  defp get_state(pid) do
    send(pid, {:get_state, self()})
    receive do
      state -> state
    end
  end

  test "Infecting works with 100% probability" do
    {:ok, pid} = Person.start_link(ExUnit.configuration()[:seed])
    %{infected: false} = get_state(pid)
    send(pid, {:infect, 1})
    %{infected: true} = get_state(pid)
  end

  test "Immune persons are not re-infected" do
    {:ok, pid} = Person.start_link(ExUnit.configuration()[:seed])

    send(pid, {:infect, 1})

    for _ <- 1..15 do
      send(pid, {:interact})
    end

    %{infected: false, immune: true} = get_state(pid)
    send(pid, {:infect, 1})
    %{infected: false, immune: true} = get_state(pid)
  end


end
