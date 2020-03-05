defmodule Simulator do
  @moduledoc false

  def start_link(seed, person_count, link_count) do
    Agent.start_link(
      fn ->
        seeds = Enum.reduce(
          0..person_count,
          [seed],
          fn (_, prev) ->
            {next, _} = :rand.uniform_s(
              round(:math.pow(2, 32) - 1),
              :rand.seed(:exsss, Enum.at(prev, 0))
            )
            [next | prev]
          end
        )
        {:ok, first_pid} = Person.start_link(seed)
        victims_list = Enum.map(
          seeds,
          fn (seed) ->
            {:ok, pid} = Person.start_link(seed)
            pid
          end
        )
        victims = 1..length(victims_list)
                  |> Stream.zip(victims_list)
                  |> Enum.into(%{})

        for victim <- victims_list do
          for peer <- Enum.map(0..link_count, fn _ -> :rand.uniform(person_count) end)
                      |> Enum.map(&Map.get(victims, &1)) do
            if victim != peer do
              Person.add_link(victim, peer)
            end
          end
        end

        Person.infect(Enum.at(victims_list, 0), 1)
        %{victims: victims_list}
      end
    )
  end

  def step(self) do
    Agent.get(
      self,
      fn state ->
        for victim <- state[:victims] do
          Person.interact(victim)
        end
      end
    )
  end

  def infected_count(self) do
    Agent.get(
      self,
      fn state ->
        Enum.map(
          state[:victims],
          fn victim ->
            if Person.is_infected(victim) do
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
end
