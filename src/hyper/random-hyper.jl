export RandomHypergraph

"""
`RandomHypergraph(n::Int,k::Int,p::Real=0.5)` creates a random 
`k`-uniform hypergraph with `n` vertices. a `k`-element 
subset of `{1,2,...,n}` is an edge (independently) with 
probility `p`.
"""
function RandomHypergraph(n::Int, k::Int, p::Real=0.5)
    H = IntHypergraph(n)
    for e in subsets(1:n,k)
        if rand() < p 
            add!(H,Set(e))
        end
    end
    return H
end 