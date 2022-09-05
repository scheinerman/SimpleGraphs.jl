# export tutte

"""
`tutte(G::UndirectedGraph, outside)` gives `G` a Tutte embedding in which 
the list of vertices in `outside` form the outer boundary. The graph 
should be connected (ideally, 3-connected) and, if planar and `outside`
defines a face, the embedding will be crossing free.

`tutte(G::UndirectedGraph)` assumes `G` has a rotation system in which case a 
largest face will be selected to be `outside`.
"""
function _tutte(G::UndirectedGraph{T}, outside::Vector{T}) where {T}
    if !issubset(outside, G.V)
        error("Some of the proposed outer vertices are not in this graph")
    end
    n = NV(G)
    VV = vlist(G)

    outside = unique(outside)  # remove dups

    lookup(v) = findfirst([v == w for w in VV])

    A = zeros(n, n)
    r = sqrt(n)

    rhs_x = zeros(n)
    rhs_y = zeros(n)

    no = length(outside)
    for j = 1:no
        theta = 2 * pi * (j - 1) / no + pi / 2
        v = outside[j]
        idx = lookup(v)
        rhs_x[idx] = r * cos(theta)
        rhs_y[idx] = r * sin(theta)
    end


    for v in G.V
        idx = lookup(v)
        A[idx, idx] = 1

        if !in(v, outside)
            d = deg(G, v)
            for w in G[v]
                j = lookup(w)
                A[idx, j] = -1 / d
            end
        end
    end

    x = A \ rhs_x
    y = A \ rhs_y

    d = Dict{T,Vector{Float64}}()
    for v in VV
        idx = lookup(v)
        d[v] = [x[idx]; y[idx]]
    end
    embed(G, d)
end


function _tutte(G::UndirectedGraph)
    FF = faces(G)
    Fmax = first(FF)
    for F in FF
        if length(F) > length(Fmax)
            Fmax = F
        end
    end
    _tutte(G, first.(Fmax))
end
