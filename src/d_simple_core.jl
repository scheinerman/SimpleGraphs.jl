# Core definitions for directed graphs

export DirectedGraph, IntDigraph, StringDigraph
export is_looped, allow_loops!, forbid_loops!, remove_loops!, loops
export out_deg, in_deg, deg, dual_deg
export in_neighbors, out_neighbors, simplify, vertex_split
export is_strongly_connected

"""
`DirectedGraph()` creates a new directed graph with vertices of `Any`
type. This can be restricted to vertics of type `T` with
`DirectedGraph{T}()`.
"""
mutable struct DirectedGraph{T} <: AbstractSimpleGraph
    V::Set{T}              # vertex set of this graph
    N::Dict{T,Set{T}}      # map vertices to out-neighbors
    NN::Dict{T,Set{T}}     # map vertices to in-neighbors
    looped::Bool           # flag to indicate if loops are allowed
    function DirectedGraph{T}() where {T}
        V = Set{T}()
        N = Dict{T,Set{T}}()
        NN = Dict{T,Set{T}}()
        G = new(V, N, NN, true)
    end
end

"""
    DG
Abbreviation for `DirectedGraph`.
"""
const DG = DirectedGraph
export DG

DirectedGraph() = DirectedGraph{Any}()
IntDigraph() = DirectedGraph{Int}()


function show(io::IO, G::DirectedGraph)
    print(io, "DirectedGraph{$(eltype(G))} (n=$(NV(G)), m=$(NE(G)))")
end


"""
`StringDigraph()` creates a new directe graph with vertices of type
`String`.
"""
StringDigraph() = DirectedGraph{String}()

eltype(G::DirectedGraph{T}) where {T} = T

"""
`IntDigraph()` creates a new directed graph with vertices of type
`Int64`.

`IntDigraph(n)` prepopulates the vertex set with vertices `1:n`.
"""
function IntDigraph(n::Int)
    G = IntDigraph()
    for v = 1:n
        add!(G, v)
    end
    return G
end

# Do we allow loops?

"""
`is_looped(G)` indicates if the directed graph `G` is capable of
having loops. Returning `true` does not mean that digraph actually
has loops.
"""
is_looped(G::DirectedGraph) = G.looped

# Grant permission for loops

"""
`allow_loops!(G)` enables `G` to have loops`.
"""
function allow_loops!(G::DirectedGraph)
    G.looped = true
    nothing
end

# Remove all loops from this digraph (but don't change loop
# permission)

"""
`remove_loops!(G)` removes all loops (if any) in the digraph, but
does *not* alter the `G`'s ability to have loops.
"""
function remove_loops!(G::DirectedGraph)
    if !G.looped
        return nothing
    end
    for v in G.V
        SimpleGraphs.delete!(G, v, v)
    end
    nothing
end

# Forbid loops (and delete any that we might have)
"""
`forbid_loops!(G)` disables the digraph's ability to have loops. It
also removes any loops it may already have.
"""
function forbid_loops!(G::DirectedGraph)
    remove_loops!(G)
    G.looped = false
    nothing
end

# List all the loops in this digraph
"""
`loops(G)` returns a list of vertices at which a loop is present.
"""
function loops(G::DirectedGraph{T}) where {T}
    if !is_looped(G)
        return T[]
    end
    loop_set = Set{T}()
    for v in G.V
        if has(G, v, v)
            push!(loop_set, v)
        end
    end
    loop_list = collect(loop_set)
    try
        sort!(loop_list)
    catch
    end
    return loop_list
end

# Out-degree of a vertex and the sequence for the whole digraph

"""
`out_deg(G,v)` is the out degree of vertex `v`.

`out_deg(G)` is a sorted list of the out degrees of all vertices in
the directed graph.
"""
out_deg(G::DirectedGraph, v) = length(G.N[v])
out_deg(G::DirectedGraph) = sort([out_deg(G, v) for v in G.V], rev = true)

# Likewise for indegrees

"""
`in_deg(G,v)` is the in degree of vertex `v`.

`in_deg(G)` is a sorted list of the in degrees of all vertices in
the directed graph.
"""
in_deg(G::DirectedGraph, v) = length(G.NN[v])
in_deg(G::DirectedGraph) = sort([in_deg(G, v) for v in G.V], rev = true)

# The degree of a vertex is the sum of in and out degrees
deg(G::DirectedGraph, v) = in_deg(G, v) + out_deg(G, v)
deg(G::DirectedGraph) = sort([deg(G, v) for v in G.V], rev = true)

# dual_deg gives the two-tuple (out,in)-degrees

"""
`dual_deg(G,v)` returns a two-tuple consisting of the out degree and
in degree of the vertex `v`.

`dual_deg(G)` gives a list of all the dual degrees.
"""
dual_deg(G::DirectedGraph, v) = (out_deg(G, v), in_deg(G, v))
dual_deg(G::DirectedGraph) = sort([dual_deg(G, v) for v in G.V], rev = true)


# out neighbors of a vertex
"""
`out_neighbors(G,v)` gives a list of all `v`'s out neighbors.
"""
function out_neighbors(G::DirectedGraph, v)
    result = collect(G.N[v])
    try
        sort!(result)
    catch
    end
    return result
end

# in neighbors of a vertex
"""
`in_neighbors(G,v)` gives a list of all of `v`'s in neighbors.
"""
function in_neighbors(G::DirectedGraph, v)
    result = collect(G.NN[v])
    try
        sort!(result)
    catch
    end
    return result
end

# Number of edges
function NE(G::DirectedGraph)
    total::Int = 0
    for v in G.V
        total += out_deg(G, v)
    end
    return total
end

# Check if this digraph has a given edge
has(G::DirectedGraph, v, w) = has(G, v) && in(w, G.N[v])

# Add a vertex to a digraph
function add!(G::DirectedGraph{T}, v) where {T}
    if has(G, v)
        return false
    end
    push!(G.V, v)
    G.N[v] = Set{T}()
    G.NN[v] = Set{T}()
    return true
end

# Add an edge to a digraph
function add!(G::DirectedGraph{T}, v, w) where {T}
    if !G.looped && v == w
        return false
    end
    if has(G, v, w)
        return false
    end
    if !has(G, v)
        add!(G, v)
    end
    if !has(G, w)
        add!(G, w)
    end
    push!(G.N[v], w)
    push!(G.NN[w], v)
    return true
end

# Delete an edge from this digraph
function SimpleGraphs.delete!(G::DirectedGraph, v, w)
    if !has(G, v, w)
        return false
    end
    SimpleGraphs.delete!(G.N[v], w)
    SimpleGraphs.delete!(G.NN[w], v)
    return true
end

# Delete a vertex from this digraph
function SimpleGraphs.delete!(G::DirectedGraph, v)
    if !has(G, v)
        return false
    end
    for w in G.N[v]
        SimpleGraphs.delete!(G, v, w)
    end
    for u in G.NN[v]
        SimpleGraphs.delete!(G, u, v)
    end
    SimpleGraphs.delete!(G.V, v)
    SimpleGraphs.delete!(G.N, v)
    SimpleGraphs.delete!(G.NN, v)
    return true
end

# Create a list of all edges in the digraph
function elist(G::DirectedGraph{T}) where {T}
    E = Set{Tuple{T,T}}()
    for v in G.V
        for w in G.N[v]
            push!(E, (v, w))
        end
    end
    result = collect(E)
    try
        sort!(result)
    catch
    end
    return result
end

# Convert a directed graph into a simple undirected graph by removing
# directions (and loops)

"""
`simplify(G::DirectedGraph)` converts a directed graph into an `UndirectedGraph`
by removing directions and loops.
"""
function simplify(D::DirectedGraph{T}) where {T}
    G = UndirectedGraph{T}()
    for v in D.V
        add!(G, v)
    end
    for e in elist(D)
        add!(G, e[1], e[2])
    end
    return G
end

# Equality check
function SimpleGraphs.isequal(G::DirectedGraph, H::DirectedGraph)
    if G.V != H.V || NE(G) != NE(H)
        return false
    end

    for e in elist(G)
        if !has(H, e[1], e[2])
            return false
        end
    end
    return true
end

function ==(G::DirectedGraph, H::DirectedGraph)
    return isequal(G, H)
end

function hash(G::DirectedGraph, h::UInt64 = UInt64(0))
    return hash(G.V, h) + hash(G.N, h)
end





# Relabel the vertics of a graph based on a dictionary mapping old
# vertex names to new
function relabel(G::DirectedGraph{S}, label::Dict{S,T}) where {S,T}
    H = DirectedGraph{T}()
    for v in G.V
        add!(H, label[v])
    end

    E = elist(G)
    for e in E
        u = label[e[1]]
        v = label[e[2]]
        add!(H, u, v)
    end
    return H
end

# Relabel the vertices with the integers 1:n
function relabel(G::DirectedGraph{S}) where {S}
    verts = vlist(G)
    n = length(verts)
    label = Dict{S,Int}()
    sizehint!(label, n)
    for idx = 1:n
        label[verts[idx]] = idx
    end

    return relabel(G, label)
end

# Split vertices of a digraph to make a bipartite undirected graph. If
# (u,v) is an edges of G, then {(u,1),(v,2)} is an edge of the new
# graph.

"""
`vertex_split(G)` converts the directed graph `G` into an undirected
bipartite graph. For each vertex `v` in `G`, the output graph has two
vertices `(v,1)` and `(v,2)`. Each edge `(v,w)` of `G` is rendered as
an edge between `(v,1)` and `(w,2)` in the output graph.
"""
function vertex_split(G::DirectedGraph{S}) where {S}
    H = UndirectedGraph{Tuple{S,Int}}()

    for v in vlist(G)
        add!(H, (v, 1))
        add!(H, (v, 2))
    end

    for e in elist(G)
        u = (e[1], 1)
        v = (e[2], 2)
        add!(H, u, v)
    end

    return H
end


"""
test if a directed graph is strongly connected by using DFS
"""
function is_strongly_connected(G::DirectedGraph{S}) where {S}
    vlist = collect(G.V)
    start = vlist[1]
    visited = zeros(Int, length(vlist))
    if (!DFS(G, start, visited))
        return false
    end

    #reverse directions of the graph
    reverseG = DirectedGraph{S}()
    for v in vlist
        add!(reverseG, v)
    end
    for e in elist(G)
        add!(reverseG, e[2], e[1])
    end

    #perform another DFS on the reverseG, is Strongly Connected if pass both tests
    visited = zeros(Int, length(vlist))
    DFS(reverseG, start, visited)
end



"""
perform a depth first search on graph G starting at vertex v
"""
function DFS(G::DirectedGraph{S}, v, visited::Array{Int,1}) where {S}
    vlist = collect(G.V)
    visited[findfirst(isequal(v), vlist)] = 1
    for i in G.N[v]
        index = findfirst(isequal(i), vlist)
        if (visited[index] != 1)
            DFS(G, vlist[index], visited)
        end
    end
    for k = 1:length(visited)
        if visited[k] == 0
            return false
        end
    end
    return true
end
