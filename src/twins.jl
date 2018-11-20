export twins

"""
`twins(G,u,v)` determines if `u` and `v` are twin vertices of `G`.
That is, if `G[u]-v == G[v]-u`. This is an equivalence relation.

`twins(G)` returns a partition of the graph's vertex set into twin
equivalence classes.
"""
function twins(G::SimpleGraph,u,v)::Bool
    @assert has(G,u) "vertex $u not in the graph"
    @assert has(G,v) "vertex $v not in the graph"

    if u==v
        return true
    end

    Nu = Set(G[u])
    Nv = Set(G[v])

    delete!(Nu,v)
    delete!(Nv,u)

    return Nu==Nv
end


function twins(G)::Partition
    VV = vlist(G)
    n  = NV(G)

    P = Partition(VV)
    for i=1:n-1
        u = VV[i]
        for j=i+1:n
            v = VV[j]
            if twins(G,u,v)
                merge_parts!(P,u,v)
            end
        end
    end
    return P
end
