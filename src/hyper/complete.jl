export CompleteHypergraph

import Combinatorics.combinations

"""
`CompleteHypergraph(n,k)` creates a complete hypergraph with vertex set
`{1,2,...,n}`. The edges are all `k`-element subsets of the vertices.
"""
function CompleteHypergraph(n::Int, k::Int)::HyperGraph{Int}
    @assert n >= 0 && k >= 0 "both arguments to CompleteHypergraph must be nonnegative"

    H = IntHyperGraph(n)

    if k > n
        return H
    end

    for e in combinations(1:n, k)
        add!(H, e)
    end

    return H
end
