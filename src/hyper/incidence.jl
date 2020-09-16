"""
`incidence(H::SimpleHypergraph)` returns the vertex-edge incidence
matrix of `H`in sparse form. Wrap in `Matrix` for full storage version.
"""
function incidence(H::SimpleHypergraph)
    n = NV(H)
    m = NE(H)
    M = spzeros(Int, n, m)

    VV = vlist(H)
    EE = elist(H)

    try
        sort!(VV)
    catch
    end


    for i = 1:n
        v = VV[i]
        for j = 1:m
            e = EE[j]
            if in(v, e)
                M[i, j] = 1
            end
        end
    end
    return M
end



# conversely, convert a matrix into a hypergraph
"""
`SimpleHypergraph(A)` where `A` is an `n`-by-`m` matrix creates a
hypergraph with `n` vertices and `m` edges determined by the nonzero entries
in the columns of `A`. This is a sort of inverse operation to `incidence`.
"""
function SimpleHypergraph(A::AbstractArray{T,2})::SimpleHypergraph{Int} where {T<:Number}
    n, m = size(A)
    H = IntHypergraph(n)

    for j = 1:m
        a = A[:, j]
        e = Set(findall(a .!= 0))
        add!(H, e)
    end
    return H
end
