# These are functions to convert SimpleGraph's to formats in Julia's
# Graphs module.

# Convert a graph or digraph into a "simple_graph".
#
# We return a triple: the simple_graph H with vertex set 1:n, a
# dictionary d mapping the vertices of G to the vertices of H, and the
# inverse dictionary dinv from V(H) to V(G).

import Graphs.simple_graph, Graphs.add_edge!
export convert_simple

"""
`convert_simple(G)` converts the `SimpleGraph` or `SimpleDigraph` to a
`simple_graph` type from Julia's `Graphs` module. This returns a
three-tuple consisting of:

* a `simple_graph` from which `G` was converted.
* a `Dict` mapping vertices of `G` to the vertices of the output graph.
* another `Dict` mapping vertics of the output graph to vertices of `G`.

Here is an example:
```
julia> G = StringGraph()
SimpleGraphs.SimpleGraph{String} (0 vertices)

julia> add!(G,"alpha", "beta")
true

julia> add!(G,"beta", "gamma")
true

julia> (g, d1, d2) = convert_simple(G);

julia> g
Undirected Graph (3 vertices, 2 edges)

julia> d1
Dict{String,Int64} with 3 entries:
  "alpha" => 1
  "gamma" => 3
  "beta"  => 2

julia> d2
Dict{Int64,String} with 3 entries:
  2 => "beta"
  3 => "gamma"
  1 => "alpha"
```
"""

function convert_simple(G::AbstractSimpleGraph)
    T = eltype(G)
    n = NV(G)
    has_dir = isa(G, SimpleDigraph)


    d = vertex2idx(G)
    dinv = Dict{Int,T}()
    for k in keys(d)
        v = d[k]
        dinv[v] = k
    end

    H = simple_graph(n, is_directed = has_dir)

    EE = elist(G)
    for e in EE
        u = d[e[1]]
        v = d[e[2]]
        add_edge!(H, u, v)
    end
    return (H, d, dinv)
end
