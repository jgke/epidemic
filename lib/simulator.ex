defmodule Simulator do
  @moduledoc false

  def start_link(seed, person_count, link_count) do
    Agent.start_link(
      fn ->
        :rand.seed(:exsss, seed)
        victims_list = Enum.map(
          0..person_count,
          fn _ ->
            {:ok, pid} = Person.start_link(:rand.uniform(round(:math.pow(2, 32))))
            pid
          end
        )
        victims = 0..length(victims_list)
                  |> Stream.zip(victims_list)
                  |> Enum.into(%{})

        relations = 0..(length(victims_list) - 1)
                    |> Enum.map(fn a -> {a, 0..link_count} end)
                    |> Enum.flat_map(fn {a, bs} -> Enum.map(bs, fn _ -> {a, :rand.uniform(person_count) - 1} end) end)
                    |> Enum.uniq()
                    |> Enum.filter(fn {a, b} -> a != b end)

        for {a, b} <- relations do
          delta = abs(a - b)
          probability = person_count / (:math.pow(delta, 2))
          Person.add_link(victims[a], victims[b], probability)
        end

        for i <- 0..min(20, length(victims_list) - 1) do
          Person.infect(victims[i], 1)
        end
        %{victims: victims, relations: relations}
      end
    )
  end

  def step(self) do
    Agent.get(
      self,
      fn state ->
        for victim <- Map.values(state[:victims]) do
          Person.interact(victim)
        end
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
        (for {k, v} <- Map.get(&1, :victims),
             into: %{},
             do: {k, Person.is_infected(v)}),
        Map.get(&1, :relations)
      }
    )
  end
end
