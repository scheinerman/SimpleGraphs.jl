"""
`incidence(H::SimpleHypergraph)` returns the vertex-edge incidence
matrix of `H`in sparse form. Wrap in `Matrix` for full storage version.
"""
function incidence(H::SimpleHypergraph)
    n = NV(H)
    m = NE(H)
    M = spzeros(Int,n,m)

    VV = vlist(H)
    EE = elist(H)

    try
        sort!(VV)
    catch
    end


    for i=1:n
        v = VV[i]
        for j=1:m
            e = EE[j]
            if in(v,e)
                M[i,j] = 1
            end
        end
    end
    return M
end
