# Functions to create standard graph matrices

import LinearAlgebraX: char_poly
export adjacency, laplace, incidence, dist_matrix, eigvals, char_poly, normalized_laplace
using SparseArrays
# Adjaceny Matrix

"""
`adjacency(G)` returns the adjacency matrix of `G`.

Note: If the vertices can be sorted by `sort`, then the first row of
the adjacency matrix corresponds to the first vertex (in order) in `G`
and so forth. However, if the vertices are not sortable in this way,
the mapping between vertices and rows/columns of the matrix is
unpredictable.
"""
function adjacency(G::UndirectedGraph)
    n = NV(G)
    A = zeros(Int, (n, n))

    # create a table from V to 1:n
    d = vertex2idx(G)

    for e in G.E
        i = d[e[1]]
        j = d[e[2]]
        A[i, j] = 1
        A[j, i] = 1
    end

    return A
end

# Laplace matrix

"""
`laplace(G)` returns the Laplacian matrix of `G`. This is the
adjacency matrix minus the (diagonal) degree matrix. See `adjacency`
to understand how vertices correspond to rows/columns of the resulting
matrix.
"""
function laplace(G::UndirectedGraph)
    A = adjacency(G)
    d = collect(sum(A, dims = 1))[:]
    D = Matrix(Diagonal(d))
    L = D - A
    return L
end


"""
    normalized_laplace(G::UndirectedGraph)
Return the normalized Laplacian matrix of `G`.
"""
function normalized_laplace(G::UndirectedGraph)::Matrix{Float64}
    n = NV(G)
    NL = zeros(Float64, (n, n))
    d = vertex2idx(G)

    for v in G.V
        if deg(G, v) > 0
            i = d[v]
            NL[i, i] = 1
        end
    end

    for e in G.E
        u, v = e
        i = d[u]
        j = d[v]
        val = -1 / sqrt(deg(G, u) * deg(G, v))
        NL[i, j] = val
        NL[j, i] = val
    end

    return NL
end

# incidence matrix

"""
`incidence(G)` returns the vertex-edge incidence matrix of `G`.

Notes:
* The result is a sparse matrix. Wrap in `Matrix` to convert to nonsparse.
* Each column of the matrix has exactly one `+1` and one `-1`. If `G`
is undirected and an unsigned incidence matrix is desired, use
`incidence(G,false)`.
"""
function incidence(G::UndirectedGraph, signed::Bool = true)
    n = NV(G)
    m = NE(G)
    M = spzeros(Int, n, m)
    d = vertex2idx(G)
    E = elist(G)
    a = 1
    b = signed ? -1 : 1

    idx = 0
    for e in E
        i = d[e[1]]
        j = d[e[2]]
        idx += 1
        M[i, idx] = a
        M[j, idx] = b
    end

    return M
end

# Create the n-by-n distance matrix
"""
`dist_matrix(G)` returns a matrix whose `i,j`-entry is the distance
from the `i`th vertex to the `j`th vertex. If there is no `i,j`-path,
that entry is `-1`.
"""
function dist_matrix(G::AbstractSimpleGraph)
    if cache_check(G, :dist_matrix)
        return cache_recall(G, :dist_matrix)
    end
    vtcs = vlist(G)
    n = length(vtcs)
    dd = dist(G)

    A = zeros(Int, n, n)

    for i = 1:n
        u = vtcs[i]
        for j = 1:n
            v = vtcs[j]
            A[i, j] = dd[(u, v)]
        end
    end
    cache_save(G, :dist_matrix, A)
    return A
end

"""
`char_poly(G)` returns the characteristic polynomial of
`adjacency(G)`. Use `char_poly(G,function)` for other
possible integer matrix functions such as `laplace`.
"""
function char_poly(G::AbstractSimpleGraph, func::Function = adjacency)
    if cache_check(G, :char_poly) && func == adjacency
        return cache_recall(G, :char_poly)
    end
    M = func(G)
    p = char_poly(M)
    if func == adjacency
        cache_save(G, :char_poly, p)
    end
    return p
end

# OLD VERSION
# function char_poly(G::AbstractSimpleGraph, func::Function=adjacency)
#     if cache_check(G,:char_poly) && func==adjacency
#       return cache_recall(G,:char_poly)
#     end
#     evs = eigvals(G,func)
#     P = poly(evs)
#     cs = round.(Int,real(coeffs(P)))
#     P =  Poly(cs)
#     if func==adjacency
#         cache_save(G,:char_poly,P)
#     end
#     return P
# end


"""
`eigvals(G)` for a `UndirectedGraph` returns the eigenvalues of `G`'s
adjacency matrix. More generally, `eigvals(G,mat)` returns the eigenvalues
of `mat(G)` where `mat` is a matrix-valued function of `G`. In particular,
one can use `mat(G,laplace)` to find the eigenvalues of `G`'s Laplacian.
"""
function LinearAlgebra.eigvals(G::UndirectedGraph, mat::Function = adjacency)
    return eigvals(mat(G))
end
