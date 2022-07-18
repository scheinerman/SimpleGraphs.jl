using SimpleGraphs, Graphs

import SimpleGraphs: UndirectedGraph, UG 
import Graphs: SimpleGraph

function UndirectedGraph(g::SimpleGraph{T})::UG{T} where {T}
    G = UG{T}()

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

function SimpleGraph(G::UG)::SimpleGraph
    H = relabel(G)
    n = NV(H)

    g = SimpleGraph(n)
    for e in H.E
        u, v = e
        add_edge!(g, u, v)
    end

    return g
end


nothing
