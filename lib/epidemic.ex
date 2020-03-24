defmodule Epidemic do
  def draw_graph(pid, filename) do
    {vertices, graph} = Simulator.get_graph(pid)
    {vertice_graph, nodes} = Enum.reduce(
      vertices,
      {
        Graphvix.Graph.new()
        |> Graphvix.Graph.set_graph_property(:outputorder, "edgesfirst"),
        %{}
      },
      fn ({person_i, state}, {graph, nodes}) ->
        color = case state do
          :infected -> "red"
          :immune -> "gray"
          :healthy -> "white"
          :dead -> "black"
        end
        {g, node} = Graphvix.Graph.add_vertex(graph, "", shape: "circle", style: "filled", fillcolor: color)
        {g, Map.put(nodes, person_i, node)}
      end
    )

    complete_graph = Enum.reduce(
      graph,
      vertice_graph,
      fn ({a, b}, graph) ->
        color = if vertices[a] == :infected or vertices[b] == :infected do
          "black"
        else
          "gray80"
        end
        {graph, _} = Graphvix.Graph.add_edge(graph, nodes[a], nodes[b], dir: "none", color: color)
        graph
      end
    )
    Graphvix.Graph.write(complete_graph, filename)
  end

  def step(pid, person_count, step, output_graph) do
      infected = Simulator.infected_count(pid)
      dead = Simulator.dead_count(pid)
      immune = Simulator.immune_count(pid)
      death_rate = dead / (dead + immune + infected)
      contact_rate = (dead + immune + infected) / person_count
      #IO.puts(
      #  "Day #{step}: #{Float.round(contact_rate * 100, 2)}% have contacted disease, #{infected} infected persons, #{
      #    dead
      #  } deaths, #{immune} immune, death rate #{Float.round(death_rate * 100, 2)}%"
      #)
      IO.puts("#{step}, #{person_count}, #{dead + immune + infected}, #{immune + infected}, #{immune}")
      Simulator.step(pid)
      if output_graph do
        draw_graph(
          pid,
          "out/#{
            step
            |> Integer.to_string
            |> String.pad_leading(3, "0")
          }_graph"
        )
      end
   if infected > 0 do
    step(pid, person_count, step+1, output_graph)
   end
  end

  def main(args \\ []) do
    {person_count_sqrt, _} = Integer.parse(Enum.at(args, 0))
    person_count = round(:math.pow(person_count_sqrt, 2))
    {link_count, _} = Integer.parse(Enum.at(args, 1))
    {infection_rate, _} = Float.parse(Enum.at(args, 3))
    output_graph = Enum.at(args, 4) == "true"

    #IO.puts("Creating simulator with #{person_count} nodes")
    {:ok, pid} = Simulator.start_link(:rand.uniform(10000), infection_rate, person_count_sqrt, link_count, 1)
    #IO.puts("\nInteracting")
    if output_graph do
      draw_graph(
        pid,
        "out/#{
          0
          |> Integer.to_string
          |> String.pad_leading(3, "0")
        }_graph"
      )
    end
    IO.puts("step,total,dead,infected,immune")
    step(pid, person_count, 1, output_graph)
    #IO.puts("Done")
  end
end
