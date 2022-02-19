export prufer_code, is_tree, prufer_restore

"""
    is_tree(G)
Determines if the `SimpleGraph` is a tree.
"""
function is_tree(G::SimpleGraph)
    return is_connected(G) && (NE(G) == NV(G) - 1)
end


"""
    lowest_leaf(G)
Return the leaf of the `SimpleGraph` with the smallest label.
"""
function lowest_leaf(G::SimpleGraph)
    leaves = [v for v ∈ G.V if deg(G, v) == 1]
    return findmin(leaves)[1]
end


"""
    lowest_leaf_neighbor(G::SimpleGraph)
Return the unique neighbor of `lowest_leaf(G)`.
"""
function lowest_leaf_neighbor(G::SimpleGraph)
    v = lowest_leaf(G)
    return G[v][1]
end

"""
    prufer_code(G)
Return the Prufer code of the `SimpleGraph` which must be a tree.
The vertices must be `<`-comparable and preferrably are the integers 
`{1,2,...,n}` (otherwise we cannot decode the sequence generated).
"""
function prufer_code(G::SimpleGraph{T})::Vector{T} where {T}
    if !is_tree(G)
        error("Graph must be a tree")
    end

    n = NV(G)

    if n < 2
        error("Graph must have at least two vertices")
    end

    if G.V != Set(1:n)
        @warn "The vertex set of this tree is not of the form {1,2,...,n}"
    end

    if n <= 2
        return T[]
    end
    GG = deepcopy(G)
    return prufer_work(GG)

end

function prufer_work(G::SimpleGraph{T})::Vector{T} where {T}
    if NV(G) <= 2
        return T[]
    end
    v = lowest_leaf(G)
    w = G[v][1]   # neighbor of lowest leaf 

    delete!(G, v)

    code = prufer_work(G)
    prepend!(code, [w])
    return code
end



"""
    prufer_restore(code::Vector{Int})
Create a tree from its Prufer code.
"""
function prufer_restore(code::Vector{Int})
    n = length(code)
    G = IntGraph(n + 2)

    # find the degree sequence of this graph 
    ds = ones(Int, n + 2)
    for v ∈ code
        ds[v] += 1
    end

    for v ∈ code
        # find first leaf in 
        leaves = [w for w ∈ G.V if ds[w] == 1]
        w = findmin(leaves)[1]
        add!(G, v, w)
        ds[v] -= 1
        ds[w] -= 1
    end

    leaves = [w for w ∈ G.V if ds[w] == 1]
    add!(G, leaves[1], leaves[2])

    return G
end

code_to_tree = prufer_restore  # for backward compatability
