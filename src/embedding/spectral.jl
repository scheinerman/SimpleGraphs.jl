export spectral!

"""
`spectral!(X::GraphEmbedding)` gives the graph held in `X` an
embedding based on the eigenvectors of the Laplacian matrix of the
graph. Specifically, the `x`-coordinates come from the eigenvector
associated with the second smallest eigenvalue, and the
`y`-coordinates come from the eigenveector associated with the third
smallest.

This may also be invoked as `spectral!(X,xcol,ycol)` to choose other
eigenvectors to use for the x and y coordinates of the embedding.
"""
function spectral!(X::GraphEmbedding,xcol::Int=2,ycol::Int=3)
    L = laplace(X.G)
    EV = eigvecs(L)
    x = EV[:,xcol]
    y = EV[:,ycol]

    VV = vlist(X.G)
    n = length(VV)

    for k=1:n
        v = VV[k]
        X.xy[v] = [x[k],y[k]]
    end
    rescale!(X)
    return X
end
