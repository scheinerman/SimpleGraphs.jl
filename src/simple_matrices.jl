# Functions to create standard graph matrices

export adjacency, char_poly, laplace, incidence, dist_matrix

# Adjaceny Matrix

"""
`adjacency(G)` returns the adjacency matrix of `G`.

Note: If the vertices can be sorted by `sort`, then the first row of
the adjacency matrix correspons to the first vertex (in order) in `G`
and so forth. However, if the vertices are not sortable in this way,
the mapping between vertices and rows/columns of the matrix is
unpredictable.
"""
function adjacency(G::SimpleGraph)
    n = NV(G)
    A = zeros(Int,(n,n))

    # create a table from V to 1:n
    d = vertex2idx(G)

    for e in G.E
        i = d[e[1]]
        j = d[e[2]]
        A[i,j]=1
        A[j,i]=1
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
function laplace(G::SimpleGraph)
    A = adjacency(G)
    d = collect(sum(A,1))[:]
    D = Base.diagm(d)
    L = D-A
    return L
end

# incidence matrix
"""

`incidence(G)` returns the vertex-edge incidence matrix of `G`.

Notes:

* The result is a sparse matrix. Wrap in `full` to convert to nonsparse.

* Each column of the matrix has exactly one `+1` and one `-1`. If `G`
is undirected and an unsigned incidence matrix is desired, use
`incidence(G,false)`.
"""
function incidence(G::SimpleGraph, signed::Bool = true)
    n = NV(G)
    m = NE(G)
    M = spzeros(Int,n,m)
    d = vertex2idx(G)
    E = elist(G)
    a = 1
    b = signed ? -1 : 1

    idx = 0
    for e in E
        i = d[e[1]]
        j = d[e[2]]
        idx += 1
        M[i,idx] = a
        M[j,idx] = b
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
    if cache_check(G,:dist_matrix)
      return cache_recall(G,:dist_matrix)
    end
    vtcs = vlist(G)
    n = length(vtcs)
    dd = dist(G)

    A = zeros(Int,n,n)

    for i = 1:n
        u = vtcs[i]
        for j = 1:n
            v = vtcs[j]
            A[i,j] = dd[(u,v)]
        end
    end
    cache_save(G,:dist_matrix,A)
    return A
end

"""
`char_poly(G)` returns the characteristic polynomial of
`adjacency(G)`.
"""
function char_poly(G::AbstractSimpleGraph)
    if cache_check(G,:char_poly)
      return cache_recall(G,:char_poly)
    end
    A = adjacency(G)
    evs = eigvals(A)
    P = poly(evs)
    cs = round(Int,real(coeffs(P)))
    P =  Poly(cs)
    cache_save(G,:char_poly,P)
    return P
end
