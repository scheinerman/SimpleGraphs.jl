# Core definitions for directed graphs

export SimpleDigraph, IntDigraph, StringDigraph
export is_looped, allow_loops!, forbid_loops!, remove_loops!, loops
export out_deg, in_deg, deg, dual_deg
export in_neighbors, out_neighbors, simplify, vertex_split
export is_strongly_connected
export directed_euler, is_cut_edge

"""
`SimpleDigraph()` creates a new directed graph with vertices of `Any`
type. This can be restricted to vertics of type `T` with
`SimpleDigraph{T}()`.
"""
mutable struct SimpleDigraph{T} <: AbstractSimpleGraph
    V::Set{T}              # vertex set of this graph
    N::Dict{T,Set{T}}      # map vertices to out-neighbors
    NN::Dict{T,Set{T}}     # map vertices to in-neighbors
    looped::Bool           # flag to indicate if loops are allowed
    function SimpleDigraph{T}() where T
        V = Set{T}()
        N = Dict{T,Set{T}}()
        NN = Dict{T,Set{T}}()
        G = new(V,N,NN,true)
    end
end

SimpleDigraph() = SimpleDigraph{Any}()
IntDigraph() = SimpleDigraph{Int}()


function show(io::IO, G::SimpleDigraph)
    print(io,"SimpleDigraph{$(vertex_type(G))} (n=$(NV(G)), m=$(NE(G)))")
end


"""
`StringDigraph()` creates a new directe graph with vertices of type
`String`.
"""
StringDigraph() = SimpleDigraph{String}()

vertex_type(G::SimpleDigraph{T}) where {T} = T

"""
`IntDigraph()` creates a new directed graph with vertices of type
`Int64`.

`IntDigraph(n)` prepopulates the vertex set with vertices `1:n`.
"""
function IntDigraph(n::Int)
    G = IntDigraph()
    for v=1:n
        add!(G,v)
    end
    return G
end

# Do we allow loops?

"""
`is_looped(G)` indicates if the directed graph `G` is capable of
having loops. Returning `true` does not mean that digraph actually
has loops.
"""
is_looped(G::SimpleDigraph) = G.looped

# Grant permission for loops

"""
`allow_loops!(G)` enables `G` to have loops`.
"""
function allow_loops!(G::SimpleDigraph)
    G.looped = true
    nothing
end

# Remove all loops from this digraph (but don't change loop
# permission)

"""
`remove_loops!(G)` removes all loops (if any) in the digraph, but
does *not* alter the `G`'s ability to have loops.
"""
function remove_loops!(G::SimpleDigraph)
    if !G.looped
        return nothing
    end
    for v in G.V
        delete!(G,v,v)
    end
    nothing
end

# Forbid loops (and delete any that we might have)
"""
`forbid_loops!(G)` disables the digraph's ability to have loops. It
also removes any loops it may already have.
"""
function forbid_loops!(G::SimpleDigraph)
    remove_loops!(G)
    G.looped = false
    nothing
end

# List all the loops in this digraph
"""
`loops(G)` returns a list of vertices at which a loop is present.
"""
function loops(G::SimpleDigraph{T}) where {T}
    if !is_looped(G)
        return T[]
    end
    loop_set = Set{T}()
    for v in G.V
        if has(G,v,v)
            push!(loop_set,v)
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
out_deg(G::SimpleDigraph, v) = length(G.N[v])
out_deg(G::SimpleDigraph) = sort([out_deg(G,v) for v in G.V], rev=true)

# Likewise for indegrees

"""
`in_deg(G,v)` is the in degree of vertex `v`.

`in_deg(G)` is a sorted list of the in degrees of all vertices in
the directed graph.
"""
in_deg(G::SimpleDigraph, v) = length(G.NN[v])
in_deg(G::SimpleDigraph) = sort([in_deg(G,v) for v in G.V], rev=true)

# The degree of a vertex is the sum of in and out degrees
deg(G::SimpleDigraph, v) = in_deg(G,v) + out_deg(G,v)
deg(G::SimpleDigraph) = sort([ deg(G,v) for v in G.V], rev=true)

# dual_deg gives the two-tuple (out,in)-degrees

"""
`dual_deg(G,v)` returns a two-tuple consisting of the out degree and
in degree of the vertex `v`.

`dual_deg(G)` gives a list of all the dual degrees.
"""
dual_deg(G::SimpleDigraph, v) = (out_deg(G,v), in_deg(G,v))
dual_deg(G::SimpleDigraph) = sort([ dual_deg(G,v) for v in G.V ], rev=true)


# out neighbors of a vertex
"""
`out_neighbors(G,v)` gives a list of all `v`'s out neighbors.
"""
function out_neighbors(G::SimpleDigraph, v)
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
function in_neighbors(G::SimpleDigraph, v)
    result = collect(G.NN[v])
    try
        sort!(result)
    catch
    end
    return result
end

# Number of edges
function NE(G::SimpleDigraph)
    total::Int = 0
    for v in G.V
        total += out_deg(G,v)
    end
    return total
end

# Check if this digraph has a given edge
has(G::SimpleDigraph, v, w) = has(G,v) && in(w,G.N[v])

# Add a vertex to a digraph
function add!(G::SimpleDigraph{T}, v) where {T}
    if has(G,v)
        return false
    end
    push!(G.V, v)
    G.N[v] = Set{T}()
    G.NN[v] = Set{T}()
    return true
end

# Add an edge to a digraph
function add!(G::SimpleDigraph{T}, v, w) where {T}
    if !G.looped && v==w
        return false
    end
    if has(G,v,w)
        return false
    end
    if !has(G,v)
        add!(G,v)
    end
    if !has(G,w)
        add!(G,w)
    end
    push!(G.N[v],w)
    push!(G.NN[w],v)
    return true
end

# Delete an edge from this digraph
function delete!(G::SimpleDigraph, v, w)
    if !has(G,v,w)
        return false
    end
    delete!(G.N[v],w)
    delete!(G.NN[w],v)
    return true
end

# Delete a vertex from this digraph
function delete!(G::SimpleDigraph, v)
    if !has(G,v)
        return false
    end
    for w in G.N[v]
        delete!(G,v,w)
    end
    for u in G.NN[v]
        delete!(G,u,v)
    end
    delete!(G.V,v)
    delete!(G.N,v)
    delete!(G.NN,v)
    return true
end

# Create a list of all edges in the digraph
function elist(G::SimpleDigraph{T}) where {T}
    E = Set{Tuple{T,T}}()
    for v in G.V
        for w in G.N[v]
            push!(E, (v,w))
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
function simplify(D::SimpleDigraph{T}) where {T}
    G = SimpleGraph{T}()
    for v in D.V
        add!(G,v)
    end
    for e in elist(D)
        add!(G,e[1],e[2])
    end
    return G
end

# Equality check
function isequal(G::SimpleDigraph, H::SimpleDigraph)
    if G.V != H.V || NE(G) != NE(H)
        return false
    end

    for e in elist(G)
        if !has(H,e[1],e[2])
            return false
        end
    end
    return true
end

function ==(G::SimpleDigraph, H::SimpleDigraph)
    return isequal(G,H)
end

function hash(G::SimpleDigraph, h::UInt64 = UInt64(0))
    return hash(G.V,h) + hash(G.N,h)
end





# Relabel the vertics of a graph based on a dictionary mapping old
# vertex names to new
function relabel(G::SimpleDigraph{S}, label::Dict{S,T}) where {S,T}
    H = SimpleDigraph{T}()
    for v in G.V
        add!(H,label[v])
    end

    E = elist(G)
    for e in E
        u = label[e[1]]
        v = label[e[2]]
        add!(H,u,v)
    end
    return H
end

# Relabel the vertices with the integers 1:n
function relabel(G::SimpleDigraph{S}) where {S}
    verts = vlist(G)
    n = length(verts)
    label = Dict{S,Int}()
    sizehint!(label,n)
    for idx = 1:n
        label[verts[idx]] = idx
    end

    return relabel(G,label)
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
function vertex_split(G::SimpleDigraph{S}) where {S}
    H = SimpleGraph{Tuple{S,Int}}()

    for v in vlist(G)
        add!(H,(v,1))
        add!(H,(v,2))
    end

    for e in elist(G)
        u = (e[1],1)
        v = (e[2],2)
        add!(H,u,v)
    end

    return H
end


"""
test if a directed graph is strongly connected by using DFS
"""
function is_strongly_connected(G::SimpleDigraph{S}) where {S}
    vlist = collect(G.V)
    start = vlist[1]
    visited = zeros(Int,length(vlist))
    if (!DFS(G,start,visited))
        return false
    end

    #reverse directions of the graph
    reverseG = SimpleDigraph{S}()
    for v in vlist
        add!(reverseG,v)
    end
    for e in elist(G)
        add!(reverseG,e[2],e[1])
    end

    #perform another DFS on the reverseG, is Strongly Connected if pass both tests
    visited = zeros(Int, length(vlist))
    DFS(reverseG,start,visited)
end



"""
perform a depth first search on graph G starting at vertex v
"""
function DFS(G::SimpleDigraph{S}, v, visited::Array{Int,1}) where S
    vlist = collect(G.V)
    visited[findfirst(isequal(v),vlist)] = 1
    for i in G.N[v]
        index = findfirst(isequal(i),vlist)
        if (visited[index] != 1)
            DFS(G,vlist[index],visited)
        end
    end
    for k = 1:length(visited)
        if visited[k] == 0
            return false
        end
    end
    return true
end


function directed_euler(G::SimpleDigraph{T}, u::T, v::T) where {T}
    notrail = T[]
    #check in_degrees and out_degrees of start and end vertex first
    if u == v
        if in_deg(G,u) != out_deg(G,u)
            return notrail
        end
    else
        if out_deg(G,u) - out_deg(G,v) != 1 ||
            in_deg(G,v) - out_deg(G,u) != 1
            return notrail
        end
    end

    #check if the undirected graph has an euler path
    simpleG = simplify(G)
    if length(euler(simpleG,u,v)) == 0
        return notrail
    end

    GG = deepcopy(G)
    return euler_work!(GG, u)

end



# determine if an edge in a directed graph is a cut edge
function is_cut_edge(G::SimpleDigrpah{T}, u::T, v::T) where {T}
    if !has(G,u,v)
        error("No such edge in this graph")
    end

    delete!(G,u,v)
    P = find_path(G,u,v)
    if (length(P) == 0)
        add!(G,u,v)
        return true
    else
        add!(G,u,v)
        return false
    end
end

# helper function to determine if there is euler path
function euler_work!(G::SimpleDigraph{T}, u::T) where {T}
    trail = T[]
    while true
        if NV(G) == 1
            append!(trail, u)
        end

        NV = out_neighbors(G,u)
        if length(NV) == 1
            v = NV[1]
            delete!(G,v)
            append!(trail,v)
            u = v
        else
            for w in NV
                if !is_cut_edge(G,u,w)
                    delete!(G,u,w)
                    append!(trail, u)
                    u = w
                    break
                end
            end
        end
    end
    error("This can't happen")
end
