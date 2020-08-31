export  is_uniform

"""
`NV(H::SimpleHypergraph)` is the number of vertices in `H`.
"""
NV(H::SimpleHypergraph) = length(H.V)

"""
`NE(H::SimpleHypergraph)` is the number of (hyper)edges in `H`.
"""
NE(H::SimpleHypergraph) = length(H.E)



function show(io::IO, H::SimpleHypergraph{T}) where T
    suffix = " (n=$(NV(H)), m=$(NE(H)))"
    print(io,"SimpleHypergraph{$T}"*suffix)
end


"""
`has(H::SimpleHypergraph{T}, v::T)` tests if `v` is a vertex of `H`.

`has(H::SimpleHypergraph{T}, e::Set{T})` tests if `e` is an edge of `H`.
Also works if `e` is a `Vector{T}` or a list of two or more arguments.
"""
function has(H::SimpleHypergraph{T}, v::T)::Bool where T
    return in(v, H.V)
end

function has(H::SimpleHypergraph{T}, e::Set{T})::Bool where T
    return in(e,H.E)
end

function has(H::SimpleHypergraph{T}, e::Vector{T})::Bool where T
    return has(H,Set(e))
end

function has(H::SimpleHypergraph{T}, e::T...)::Bool where T
    return has(H,set(e))
end

"""
`H[v]` for a hypergraph `H` and vertex `v` returns the set of edges
that contain vertex `v`. This throws an error if `v` is not a vertex
of `H`.
"""
function getindex(H::SimpleHypergraph{T}, v::T)::Set{Set{T}} where T
    if !has(H,v)
        error("No such vertex: $v")
    end
    return H.VE[v]
end

function deg(H::SimpleHypergraph{T}, v::T)::Int where T
    return length(H[v])
end

function eltype(H::SimpleHypergraph{T}) where T
    return T
end

"""
`vlist(H::SimpleHypergraph)` returns a list of the vertices
in `H`.
"""
function vlist(H::SimpleHypergraph)
    return collect(H.V)
end

"""
`elist(H::SimpleHypergraph)` returns a list of the edges
in `H`.
"""
function elist(H::SimpleHypergraph)
    return collect(H.E)
end



function is_uniform(H::SimpleHypergraph{T})::Bool where T
    if NE(H) < 2
        return true
    end
    klist = length.(collect(H.E))  # get sizes of all edges
    n = length(unique(klist))      # throw away duplicates
    return n==1
end
