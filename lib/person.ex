defmodule Person do
  def start_link(seed) do
    Agent.start_link(
      fn ->
        :rand.seed(:exsss, seed)
        %{
          connections: %{},
          infected: false,
          cured_at: 0,
          immune: false,
          dead: false,
        }
      end
    )
  end

  def add_link(self, person, probability) do
    Agent.update(self, &Map.put(&1, :connections, Map.put(Map.get(&1, :connections), person, probability)))
  end

  def infect(self, probability) do
    Agent.update(
      self,
      fn state ->
        if not state[:immune] and not state[:infected] do
          roll = :rand.uniform()
          if probability > roll do
            %{state | infected: true, cured_at: 14}
          else
            state
          end
        else
          state
        end
      end
    )
  end

  defp step_infection(state) do
    roll = :rand.uniform()
    if roll > 0.999 do
      %{state | dead: true}
    else
      %{state | cured_at: state[:cured_at] - 1}
    end
  end

  def interact(self) do
    Agent.get_and_update(
      self,
      fn state ->
        cond do
          state[:dead] -> {[], state}
          state[:infected] and state[:cured_at] == 0 ->
            {[], %{state | infected: false, immune: true}}
          state[:infected] ->
            {state[:connections], step_infection(state)}
          true -> {[], state}
        end
      end
    )
  end

  def is_infected(self) do
    get_state(self) == :infected
  end

  def is_dead(self) do
    get_state(self) == :dead
  end

  def is_immune(self) do
    get_state(self) == :immune
  end

  def get_state(self) do
    Agent.get(
      self,
      &(cond do
          Map.get(&1, :dead) -> :dead
          Map.get(&1, :immune) -> :immune
          Map.get(&1, :infected) -> :infected
          true -> :healthy
        end)
    )
  end
end
