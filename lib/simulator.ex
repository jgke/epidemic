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

        for {i, victim} <- Enum.zip(0..length(victims_list), victims_list) do
          for {peer_i, peer} <- Enum.map(0..link_count, fn _ -> :rand.uniform(person_count) - 1 end)
                      |> Enum.map(fn pos -> {pos,  Map.get(victims, pos)} end) do
            if victim != peer do
              delta = abs(i - peer_i)
              probability = person_count / (:math.pow(delta, 2))
              Person.add_link(victim, peer, probability)
            end
          end
        end

        for i <- 0..min(20, length(victims_list)) do
          Person.infect(Enum.at(victims_list, i), 1)
        end
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

  defp get_count(self, cb) do
    Agent.get(
      self,
      fn state ->
        Enum.map(
          state[:victims],
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
end
