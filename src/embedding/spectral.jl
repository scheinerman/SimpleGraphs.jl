
"""
`_spectral(G)` Gives the graph held an
embedding based on the eigenvectors of the Laplacian matrix of the
graph. Specifically, the `x`-coordinates come from the eigenvector
associated with the second smallest eigenvalue, and the
`y`-coordinates come from the eigenveector associated with the third
smallest.

This may also be invoked as `_spectral(G,xcol,ycol)` to choose other
eigenvectors to use for the x and y coordinates of the embedding.
"""
function _spectral(G::SimpleGraph, xcol::Int = 2, ycol::Int = 3)
    L = laplace(G)
    EV = eigvecs(L)
    x = EV[:, xcol]
    y = EV[:, ycol]

    VV = vlist(G)
    n = length(VV)

    for k = 1:n
        v = VV[k]
        G.cache[:xy][v] = [x[k], y[k]]
    end
    scale(G)
end

"""
    _normalized_spectral(G::SimpleGraph, xcol::Int = 2, ycol::Int = 3)
Same as `_spectral`, but use the normalized Laplacian matrix.
"""
function _normalized_spectral(G::SimpleGraph, xcol::Int = 2, ycol::Int = 3)
    L = normalized_laplace(G)
    EV = eigvecs(L)
    x = EV[:, xcol]
    y = EV[:, ycol]

    VV = vlist(G)
    n = length(VV)

    for k = 1:n
        v = VV[k]
        G.cache[:xy][v] = [x[k], y[k]]
    end
    scale(G)
end
