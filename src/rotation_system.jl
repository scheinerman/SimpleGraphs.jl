export rand_rot, set_rot, get_rot, check_rot, faces, euler_char
export embed_rot, NF, dual


"""
`rand_rot(G::SimpleGraph)` creates a random rotation system for 
the graph.
"""
function rand_rot(G::SimpleGraph{T}) where {T}
    d = Dict{T,RingList{T}}()
    for v in G.V
        a = shuffle(RingList(G[v]))
        d[v] = a
    end
    set_rot(G, d)
end

"""
`_default_rot(G::SimpleGraph)` creates a default 
rotation system for the graph.
"""
function _default_rot(G::SimpleGraph{T}) where {T}
    d = Dict{T,RingList{T}}()
    for v in G.V
        d[v] = RingList(G[v])
    end
    return d
end

"""
`set_rot(G::SimpleGraph,d)` makes `d` the rotation system 
for this graph (held in the graph's cache).

If `d` is omitted, the a default rotation is used.
"""
function set_rot(G::SimpleGraph, d)
    if !check_rot(G, d)
        error("Not a valid rotation system for this graph")
    end
    cache_save(G, :RotationSystem, d)
    nothing
end
set_rot(G::SimpleGraph) = set_rot(G, _default_rot(G))


"""
`get_rot(G::SimpleGraph,v)` returns a `RingList` of the neighbors of `v`.
This assumes that `G` has an associate rotation system. If not, one is 
generated and an alert is generated.

`get_rot(G::SimpleGraph)` returns  a copy of the rotation system associated with `G`
(or an error if there is no rotation system). 
"""
function get_rot(G::SimpleGraph, v)
    if !has(G, v)
        error("No such vertex $v in this graph")
    end
    d = get_rot(G)
    return d[v]
end
function get_rot(G::SimpleGraph)
    if cache_check(G, :RotationSystem)
        return cache_recall(G, :RotationSystem)
    end

    if cache_check(G, :GraphEmbedding)
        embed_rot(G)
        @info "Giving this graph, $G, a rotation system based on its xy-embedding."
    else
        set_rot(G)
        @info "Giving this graph, $G, a default rotation system."
    end
    return get_rot(G)
end



"""
`embed_rot(G::SimpleGraph)` assigns a rotation system to `G`
corresponding to its current `xy` embedding.
"""
function embed_rot(G::SimpleGraph{T}) where {T}
    xy = getxy(G)
    d = Dict{T,RingList{T}}()
    for v in G.V
        o = Complex(xy[v]...)    # location of v as a complex number
        Nv = G[v]  # neighbors of v as a list 

        Z = [Complex(xy[w]...) for w in Nv]  # neighbor locations as complex nums
        th = [mod(angle(o - z), 2pi) for z in Z]  # angles of edges from v 
        p = sortperm(th)
        d[v] = RingList(Nv[p])
    end
    set_rot(G, d)
end


"""
`check_rot(G::SimpleGraph,d::Dict)`  checks if `d` is a valid 
rotation system for `G`. 
"""
function check_rot(G::SimpleGraph{T}, d::Dict{T,RingList{T}}) where {T}
    for v in G.V
        if !haskey(d, v)
            return false
        end
        if Set(d[v]) != Set(G[v])
            return false
        end
    end
    return true
end



function _next_edge(G::SimpleGraph{T}, uv::Tuple{T,T}) where {T}
    u, v = uv
    r = get_rot(G, v)
    w = r(u)
    return (v, w)
end


"""
`_trace_face(G::SimpleGraph, v,w)` uses the graph's rotation system to find a 
face starting with the edge `(u,v)` (in that order). Also may be called 
by `_trace_face(G,(u,v))`.
"""
function _trace_face(G::SimpleGraph{T}, uv::Tuple{T,T}) where {T}
    data = T[]
    u, v = uv
    push!(data, u)
    push!(data, v)
    e = uv
    while true
        vw = _next_edge(G, e)
        if vw == uv
            break
        end
        push!(data, vw[2])
        e = vw
    end

    boundary = [(data[i], data[i+1]) for i = 1:length(data)-1]

    return RingList(boundary)
end
_trace_face(G::SimpleGraph{T}, u::T, v::T) where {T} = _trace_face(G, (u, v))


"""
`faces(G::SimpleGraph)` returns the set of faces of this graph 
(given its rotation system). The rotation system is a 
planar embedding iff this returns `2`.

Each face is a `RingList` of the (directed) edges bordering the face.

*Requires that the graph is connected and has at least one edge.*
"""
function faces(G::SimpleGraph{T}) where {T}
    FT = RingList{Tuple{T,T}}   # type of an oriented face 
    result = Set{FT}()

    for e in G.E
        u, v = e
        F = _trace_face(G, u, v)
        push!(result, F)
        F = _trace_face(G, v, u)
        push!(result, F)
    end

    return result
end

"""
`NF(G)` returns the number of faces in the graph `G`
given its current rotation system.

*Requires that the graph is connected and has at least one edge.*
"""
NF(G::SimpleGraph) = length(faces(G))

"""
`euler_char(G::SimpleGraph)` computes the Euler characteristic 
of the graph `G` with its associated rotation system. 
Specifically, `euler_char(G)` returns `NV(G) - NE(G) + NF(G)`.

*Requires that the graph is connected and has at least one edge.*
"""
euler_char(G::SimpleGraph) = NV(G) - NE(G) + NF(G)




"""
`dual(G::SimpleGraph)` returns the dual graph of `G`.
The vertices of the dual are the faces of `G` and they are 
adjacent if and only if they share a common edge. 

*Requires that the graph is connected and has at least one edge.*
"""
function dual(G::SimpleGraph{T}) where {T}
    F = collect(faces(G))
    S = RingList{Tuple{T,T}}
    GG = SimpleGraph{S}()
    # the faces of G are the vertices of GG
    for f in F
        add!(GG, f)
    end

    # two faces are adjacent if one has (a,b) and the other (b,a)
    n = NV(GG)
    for i = 1:n-1
        f = F[i]
        for j = i+1:n
            g = F[j]
            for e in f
                if in(reverse(e), g)
                    add!(GG, f, g)
                end
            end
        end
    end
    name(GG, "Dual of $(name(G))")
    return GG
end
