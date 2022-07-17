using SimpleGraphs, Graphs

"""
    graph_convert 
Both `Graphs` and `SimpleGraphs` define a graph type named `SimpleGraph`.
This function is used to convert between the two.

If `g` is a `Graphs.SimpleGraph` then `graph_convert(g)` returns a 
`SimpleGraphs.SimpleGraph` with exactly the same vertices and edges as `g`.

Conversion in the other direction is more complicated because the `SimpleGraphs` 
module allows  arbitrary sets of vertices, whereas `Graphs` require graphs to have 
vertex sets of the form `{1,2,...,n}`. 

When `graph_convert` is applied to a graph `G`
of type `SimpleGraphs.SimpleGraph` it first makes a copy of `G` with vertices 
relabeled to be integers from `1` to `n`, and then uses that copy to make a 
`Graphs.SimpleGraph`. See `SimpleGraphs.relabel`.
"""
function graph_convert(g::Graphs.SimpleGraph{T})::SimpleGraphs.SimpleGraph{T} where {T}
    G = SimpleGraphs.SimpleGraph{T}()

    for v in vertices(g)
        add!(G, v)
    end

    for e in edges(g)
        u = e.dst
        v = e.src
        add!(G, u, v)
    end

    return G
end

function graph_convert(G::SimpleGraphs.SimpleGraph)::Graphs.SimpleGraph
    H = relabel(G)
    n = NV(H)

    g = Graphs.SimpleGraph(n)
    for e in H.E
        u, v = e
        add_edge!(g, u, v)
    end

    return g

end
