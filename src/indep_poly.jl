export indep_poly

"""
`indep_poly(G)` returns the independence polynomial of the `UndirectedGraph` `G`.
"""
function indep_poly(G::UndirectedGraph, cache_flag::Bool = true)
    if cache_flag && cache_check(G, :indep_poly)
        return cache_recall(G, :indep_poly)
    end

    if NV(G) == 0
        p = SimplePolynomial([1])
        if cache_flag
            cache_save(G, :indep_poly, p)
        end
        return p
    end
    if NE(G) == 0
        p = SimplePolynomial([1, 1])^NV(G)
        if cache_flag
            cache_save(G, :indep_poly, p)
        end
        return p
    end

    if is_connected(G)
        v = first(G.V)  # get any edge
        Nv = G[v]

        G1 = deepcopy(G)
        SimpleGraphs.delete!(G1, v)
        p1 = indep_poly(G1, false)
        for w in Nv
            SimpleGraphs.delete!(G1, w)
        end
        p2 = indep_poly(G1, false)

        p = p1 + SimplePolynomial([0, 1]) * p2
        if cache_flag
            cache_save(G, :indep_poly, p)
        end
        return p
    end

    comps = parts(components(G))
    p = SimplePolynomial([1])
    for S in comps
        H = induce(G, S)
        pH = indep_poly(H, false)
        p *= pH
    end
    if cache_flag
        cache_save(G, :indep_poly, p)
    end
    return p
end
