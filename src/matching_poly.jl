export matching_poly

"""
`matching_poly(G)` returns the matching polynomial of the
`SimpleGraph` `G`.
"""

function matching_poly(G::SimpleGraph, cache_flag::Bool=true)
    if cache_flag && cache_check(G,:matching_poly)
        return cache_recall(G,:matching_poly)
    end
    if NE(G)==0
        p = Poly([0,1])^NV(G)
        if cache_flag
            SimpleGraphs.cache_save(G,:matching_poly,p)
        end
        return p
    end

    if is_connected(G)
        e = first(G.E)  # get any edge
        v,w = e

        G1 = deepcopy(G)
        delete!(G1,v,w)
        p1 = matching_poly(G1,false)

        delete!(G1,v)
        delete!(G1,w)
        p2 = matching_poly(G1,false)

        p = p1 - p2
        if cache_flag
            SimpleGraphs.cache_save(G,:matching_poly,p)
        end
        return p
    end

    comps = parts(components(G))
    p = Poly([1])
    for S in comps
        H = induce(G,S)
        pH = matching_poly(H,false)
        p *= pH
    end
    if cache_flag
        SimpleGraphs.cache_save(G,:matching_poly,p)
    end
    return p
end
