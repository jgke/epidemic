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
      Person.interact(pid)
    end

    false = Person.is_infected(pid)
    Person.infect(pid, 1)
    false = Person.is_infected(pid)
  end

  test "Persons can infect other people" do
    {:ok, p1} = Person.start_link(get_seed())
    {:ok, p2} = Person.start_link(get_seed())

    Person.add_link(p1, p2)

    false = Person.is_infected(p2)
    Person.infect(p1, 1)
    Person.interact(p1)
    true = Person.is_infected(p2)
  end


  @tag timeout: 120_000
  test "Simulator runs" do
    IO.inspect("Creating simulator")
    person_count = 100_000
    link_count = 10
    {:ok, pid} = Simulator.start_link(get_seed(), person_count, link_count)
    IO.inspect("Interacting")
    for step <- 1..45 do
      infected = Simulator.infected_count(pid)
      dead = Simulator.dead_count(pid)
      immune = Simulator.immune_count(pid)
      death_rate = dead / (dead + immune + infected)
      contact_rate = (dead + immune + infected) / person_count
      IO.puts("Step #{step}: #{Float.round(contact_rate * 100, 2)}% have contacted disease, #{infected} infected persons, #{dead} deaths, #{immune} immune, death rate #{Float.round(death_rate * 100, 2)}%")
      Simulator.step(pid)
    end
    IO.inspect("Done")
  end
end
