defmodule Person do
  def start_link(seed) do
    Agent.start_link(
      fn ->
        %{
          seed: :rand.seed(:exsss, seed),
          connections: [],
          infected: false,
          cured_at: 0,
          immune: false,
        }
      end
    )
  end

  def add_link(self, person) do
    Agent.update(self, &Map.put(&1, :connections, [person | Map.get(&1, :connections)]))
  end

  def infect(self, probability) do
    Agent.update(
      self,
      fn state ->
        if not state[:immune] and not state[:infected] do
          {roll, next} = :rand.uniform_s(state[:seed])
          if probability > roll do
            %{state | infected: true, cured_at: 14, seed: next}
          else
            state
          end
        else
          state
        end
      end
    )
  end

  def interact(self) do
    Agent.update(
      self,
      fn state ->
        cond do
          state[:infected] and state[:cured_at] == 0 ->
            %{state | infected: false, immune: true}
          state[:infected] and length(state[:connections]) > 0 ->
            {roll, next} = :rand.uniform_s(length(state[:connections]), state[:seed])
            Person.infect(Enum.at(state[:connections], roll - 1), 1)
            %{state | cured_at: state[:cured_at] - 1, seed: next}
          state[:infected] ->
            %{state | cured_at: state[:cured_at] - 1}
          true -> state
        end
      end
    )
  end

  def is_infected(self) do
    Agent.get(self, &Map.get(&1, :infected))
  end

  #defp loop(state) do
  #  receive do
  #    {:add_link, person} ->
  #      loop(%{state | connections: [person | state[:connections]]})

  #    {:interact} ->

  #    {:infect, probability} ->

  #    {:get_state, caller} ->
  #      send(caller, state)
  #      loop(state)
  #  end
  #end
end
