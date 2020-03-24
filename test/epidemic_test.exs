defmodule EpidemicTest do
  use ExUnit.Case
  doctest Epidemic

  defp get_seed() do
    ExUnit.configuration()[:seed]
  end

  test "Infecting works with 100% probability" do
    {:ok, pid} = Person.start_link(get_seed())
    IO.inspect(pid)
    false = Person.is_infected(pid)
    Person.infect(pid, 1)
    true = Person.is_infected(pid)
  end

  test "Immune persons are not re-infected" do
    {:ok, pid} = Person.start_link(get_seed())

    Person.infect(pid, 1)

    for _ <- 1..15 do
      Person.interact(pid, 0)
    end

    false = Person.is_infected(pid)
    Person.infect(pid, 1)
    false = Person.is_infected(pid)
  end

  test "Persons can infect other people" do
    {:ok, p1} = Person.start_link(get_seed())
    {:ok, p2} = Person.start_link(get_seed())

    Person.add_link(p1, p2, 1)

    false = Person.is_infected(p2)
    Person.infect(p1, 1)
    assert Person.interact(p1, 0) == %{p2 => 1}
  end


  @tag timeout: 120_000
  test "Simulator runs" do
    IO.puts("Creating simulator")
    infection_rate = 1
    person_count_sq = 100
    person_count = person_count_sq * person_count_sq
    link_count = 3
    {:ok, pid} = Simulator.start_link(get_seed(), infection_rate, person_count_sq, link_count, 5)
    IO.puts("Interacting")
    for step <- 1..120 do
      infected = Simulator.infected_count(pid)
      if infected > 0 do   
        dead = Simulator.dead_count(pid)
        immune = Simulator.immune_count(pid)
        death_rate = dead / (dead + immune + infected)
        contact_rate = (dead + immune + infected) / person_count
        IO.puts("Day #{step}: #{Float.round(contact_rate * 100, 2)}% have contacted disease, #{infected} infected persons, #{dead} deaths, #{immune} immune, death rate #{Float.round(death_rate * 100, 2)}%")
        Simulator.step(pid)
      end
    end
    IO.puts("Done")
  end
end
