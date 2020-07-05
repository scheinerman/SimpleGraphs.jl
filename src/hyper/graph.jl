"""
`SimpleGraph(H::SimpleHypergraph)` demotes a hypergraph to
a simple graph.
"""
function SimpleGraph(H::SimpleHypergraph{T})::SimpleGraph{T} where T
    G = SimpleGraph{T}()

    # copy all vertices
    for v in H.V
        add!(G,v)
    end

    # for all pairs of vertices in all edges, create an edge in G
    for e in H.E
        if length(e) < 2
            continue
        end

        ee = collect(e)
        k = length(ee)

        for i=1:k-1
            u = ee[i]
            for j=i+1:k
                v = ee[j]
                add!(G,u,v)
            end
        end
    end
    return G
end

"""
`SimpleHypergraph{T}()` creates a new hypergraph in which vertices have
type `T`. **Warning**: Do not use `T=Any`.

`SimpleHypergraph(G::SimpleGraph)` converts a graph to
the equivalent two-uniform hypergraph.
"""
function SimpleHypergraph(G::SimpleGraph{T}) where T
    H = SimpleHypergraph{T}()
    for v in G.V
        add!(H,v)
    end

    for e in G.E
        u,v = e
        add!(H,u,v)
    end

    return H
end
