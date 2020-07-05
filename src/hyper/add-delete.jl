### ADDING  ###

"""
`add!(H::SimpleHypergraph{T}, v::T)` to add a vertex to `H`. **Example**:
`add!(H,3)`.

`add!(H::SimpleHypergraph{T}, e::Set{T})` to add a hyperedge. This
also works if `e` is a one-dimensional array of `T`s.
**Example**: `add!(H,[1,2,3])`.
"""
function add!(H::SimpleHypergraph{T},v::T)::Bool where T
    if in(v,H.V)
        return false
    end
    push!(H.V, v)
    H.VE[v] = Set{Set{T}}()
    return true
end

function add!(H::SimpleHypergraph{T}, e::Set{T})::Bool where T
    if in(e,H.E)
        return false  # already have this edge
    end

    # make sure we have all the vertices
    for v in e
        add!(H,v)
    end

    # add the edge
    push!(H.E, e)

    # update the VE dictionary
    for v in e
        push!(H.VE[v],e)
    end

    return true
end

function add!(H::SimpleHypergraph{T}, e::Vector{T})::Bool where T
    add!(H,Set(e))
end

function add!(H::SimpleHypergraph{T}, e::T...) where T
    add!(H,Set(e))
end


### DELETING ###

"""
`delete!(H::SimpleHypergraph,v)` deletes vertex `v` from `H` as well as
all edges that contain `v`.

`delete!(H::SimpleHypergraph,e)` deletes edge `e` from `H`. Here,
`e` is either a `Set` or a `Vector` of vertices.
"""
function delete!(H::SimpleHypergraph{T}, e::Set{T})::Bool where T
    if !has(H,e)   # nothing to do if this edge isn't in H
        return false
    end

    # Delete e from H.E
    delete!(H.E, e)

    # for every v in e, delete e from VE[v]
    for v in e
        delete!(H.VE[v], e)
    end

    return true
end

function delete!(H::SimpleHypergraph{T}, e::Vector{T})::Bool where T
    delete!(H, Set(e))
end


function delete!(H::SimpleHypergraph{T}, e::T...) where T
    delete!(H,Set(e))
end

function delete!(H::SimpleHypergraph{T}, v::T)::Bool where T
    if !has(H,v)
        return false
    end

    # delete all edges that contain v
    for e in H[v]
        delete!(H,e)
    end

    # delete v from H.V
    delete!(H.V, v)

    return true
end
