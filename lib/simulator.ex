defmodule Simulator do
  @moduledoc false

  def distance(person_count, a, b) do
    x1 = rem(a, person_count)
    y1 = div(a, person_count)
    x2 = rem(b, person_count)
    y2 = div(b, person_count)
    dx = abs(x1 - x2)
    dy = abs(y1 - y2)
    {dx, dy}
  end

  def start_link(seed, infection_rate, person_count, link_probability, initial_infected) do
    Agent.start_link(
      fn ->
        :rand.seed(:exsss, seed)
        victim_count = person_count * person_count - 1
        victims_list = Enum.map(
          0..victim_count,
          fn _ ->
            {:ok, pid} = Person.start_link(:rand.uniform(round(:math.pow(2, 32))))
            pid
          end
        )
        victims = 0..length(victims_list)
                  |> Stream.zip(victims_list)
                  |> Enum.into(%{})

        relations =
          0..victim_count
          |> Flow.from_enumerable()
          |> Flow.map(fn a -> {a, 0..victim_count} end)
          |> Flow.flat_map(
               fn {a, bs} ->
                 Enum.map(
                   bs,
                   fn b ->
                     {dx, dy} = distance(person_count, a, b)
                     {a, b, dx < :rand.normal() * link_probability, dy < :rand.normal() * link_probability}
                   end
                 )
               end
             )
          |> Flow.filter(fn {a, b, px, py} -> a != b and px and py end)
          |> Flow.flat_map(fn {a, b, _, _} -> [{a, b}, {b, a}] end)
          |> Enum.to_list
        IO.puts("Average #{Float.round(length(relations)/(victim_count*2), 2)} connections per node")

        for {a, b} <- relations do
          {dx, dy} = distance(person_count, a, b)
          delta = round(:math.sqrt(:math.pow(dx, 2) + :math.pow(dy, 2)))
          probability = (person_count / (100 * delta)) * infection_rate
          Person.add_link(victims[a], victims[b], probability)
        end

        for i <- 0..(initial_infected-1) do
          Person.infect(victims[i], 1)
        end
        %{victims: victims, relations: Enum.filter(relations, fn {a, b} -> a < b end)}
      end
    )
  end

  def step(self) do
    Agent.get(
      self,
      fn state ->
        Map.values(state[:victims])
        |> Enum.flat_map(&Person.interact/1)
        |> Enum.map(fn {pid, p} -> Person.infect(pid, p) end)
        :ok
      end
    )
  end

  defp get_count(self, cb) do
    Agent.get(
      self,
      fn state ->
        Enum.map(
          Map.values(state[:victims]),
          fn victim ->
            if cb.(victim) do
              1
            else
              0
            end
          end
        )
        |> Enum.sum
      end
    )
  end

  def infected_count(self) do
    get_count(self, fn victim -> Person.is_infected(victim) end)
  end

  def dead_count(self) do
    get_count(self, fn victim -> Person.is_dead(victim) end)
  end

  def immune_count(self) do
    get_count(self, fn victim -> Person.is_immune(victim) end)
  end

  def get_graph(self) do
    Agent.get(
      self,
      &{
        Map.get(&1, :victims)
        |> Enum.map(
             fn {k, v} ->
                {k, Person.get_state(v)}
             end
           )
        |> Map.new,
        Map.get(&1, :relations)
      }
    )
  end
end
