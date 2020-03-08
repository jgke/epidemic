defmodule Epidemic do
  def draw_graph(pid, filename) do
    {vertices, graph} = Simulator.get_graph(pid)
    {vertice_graph, nodes} = Enum.reduce(
      vertices,
      {Graphvix.Graph.new(), %{}},
      fn ({person_i, infected}, {graph, nodes}) ->
        {g, node} = if infected do
          Graphvix.Graph.add_vertex(graph, person_i, style: "filled", fillcolor: "red")
        else
          Graphvix.Graph.add_vertex(graph, person_i)
        end
        {g, Map.put(nodes, person_i, node)}
      end
    )
    complete_graph = Enum.reduce(
      graph,
      vertice_graph,
      fn ({a, b}, graph) ->
        {graph, _} = Graphvix.Graph.add_edge(graph, nodes[a], nodes[b], dir: "none")
        graph
      end
    )
    Graphvix.Graph.write(complete_graph, filename)
  end

  def main(args \\ []) do
    IO.inspect("Creating simulator")
    {person_count, _} = Integer.parse(Enum.at(args, 0))
    {link_count, _} = Integer.parse(Enum.at(args, 1))
    {steps, _} = Integer.parse(Enum.at(args, 2))

    {:ok, pid} = Simulator.start_link(:rand.uniform(10000), person_count, link_count)
    IO.inspect("Interacting")
    for step <- 1..steps do
      infected = Simulator.infected_count(pid)
      dead = Simulator.dead_count(pid)
      immune = Simulator.immune_count(pid)
      death_rate = dead / (dead + immune + infected)
      contact_rate = (dead + immune + infected) / person_count
      IO.puts(
        "Day #{step}: #{Float.round(contact_rate * 100, 2)}% have contacted disease, #{infected} infected persons, #{
          dead
        } deaths, #{immune} immune, death rate #{Float.round(death_rate * 100, 2)}%"
      )
      Simulator.step(pid)
      draw_graph(pid, "out/#{step |> Integer.to_string |> String.pad_leading(3, "0")}_graph")
    end
    IO.inspect("Done")
  end
end
