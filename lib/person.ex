defmodule Person do
  def start_link(seed) do
    Task.start_link(
      fn ->
        loop(
          %{
            seed: :rand.seed(:exsss, seed),
            connections: [],
            infected: false,
            cured_at: 0,
            immune: false,
          }
        )
      end
    )
  end

  defp loop(state) do
    receive do
      {:add_link, _person} ->
        loop(state)

      {:interact} ->
        if state[:infected] do
          if length(state[:connections]) > 0 and state[:infected] do
            # todo
          end
          if state[:cured_at] == 0 do
            loop(%{state | infected: false, immune: true})
          else
            loop(%{state | cured_at: state[:cured_at] - 1})
          end
        else
          loop(state)
        end

      {:infect, probability} ->
        if not state[:immune] and not state[:infected] do
          {roll, next} = :rand.uniform_s(state[:seed])
          if probability > roll do
            loop(%{state | infected: true, cured_at: 14, seed: next})
          end
        else
          loop(state)
        end

      {:get_state, caller} ->
        send(caller, state)
        loop(state)
    end
  end
end
