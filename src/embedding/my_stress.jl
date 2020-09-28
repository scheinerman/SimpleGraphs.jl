# THIS FILE TAKEN FROM GraphLayout AND EDITED SO IT WORKS

"""
Compute graph layout using stress majorization

Inputs:

    δ: Matrix of pairwise distances
    p: Dimension of embedding (default: 2)
    w: Matrix of weights. If not specified, defaults to
           w[i,j] = δ[i,j]^-2 if δ[i,j] is nonzero, or 0 otherwise
    X0: Initial guess for the layout. Coordinates are given in rows.
        If not specified, default to random matrix of Gaussians

Additional optional keyword arguments control the convergence of the algorithm
and the additional output as requested:

    maxiter:   Maximum number of iterations. Default: 400size(X0, 1)^2
    abstols:   Absolute tolerance for convergence of stress.
               The iterations terminate if the difference between two
               successive stresses is less than abstol.
               Default: √(eps(eltype(X0))
    reltols:   Relative tolerance for convergence of stress.
               The iterations terminate if the difference between two
               successive stresses relative to the current stress is less than
               reltol. Default: √(eps(eltype(X0))
    abstolx:   Absolute tolerance for convergence of layout.
               The iterations terminate if the Frobenius norm of two successive
               layouts is less than abstolx. Default: √(eps(eltype(X0))
    verbose:   If true, prints convergence information at each iteration.
               Default: false
    returnall: If true, returns all iterates and their associated stresses.
               If false (default), returns the last iterate

Output:

    The final layout X, with coordinates given in rows, unless returnall=true.

Reference:

    The main equation to solve is (8) of:

    @incollection{
        author = {Emden R Gansner and Yehuda Koren and Stephen North},
        title = {Graph Drawing by Stress Majorization}
        year={2005},
        isbn={978-3-540-24528-5},
        booktitle={Graph Drawing},
        seriesvolume={3383},
        series={Lecture Notes in Computer Science},
        editor={Pach, J\'anos},
        doi={10.1007/978-3-540-31843-9_25},
        publisher={Springer Berlin Heidelberg},
        pages={239--250},
    }
"""
function my_layout_stressmajorize_adj(
    δ,
    p::Int = 2,
    w = nothing,
    X0 = randn(size(δ, 1), p);
    maxiter = 400size(X0, 1)^2,
    abstols = √(eps(eltype(X0))),
    reltols = √(eps(eltype(X0))),
    abstolx = √(eps(eltype(X0))),
    verbose = false,
    returnall = false,
)

    @assert size(X0, 2) == p

    if w == nothing
        w = δ .^ -2
        w[.!isfinite.(w)] .= 0
    end

    @assert size(X0, 1) == size(δ, 1) == size(δ, 2) == size(w, 1) == size(w, 2)
    Lw = weightedlaplacian(w)
    pinvLw = pinv(Lw)
    newstress = stress(X0, δ, w)
    Xs = Matrix[X0]
    stresses = [newstress]
    itcounter = 0
    for iter = 1:maxiter
        itcounter = iter
        #TODO the faster way is to drop the first row and col from the iteration
        X = pinvLw * (LZ(X0, δ, w) * X0)
        @assert all(isfinite.(X))
        newstress, oldstress = stress(X, δ, w), newstress
        verbose && info("""Iteration $iter
        Change in coordinates: $(vecnorm(X - X0))
        Stress: $newstress (change: $(newstress-oldstress))
        """)
        push!(Xs, X)
        push!(stresses, newstress)
        abs(newstress - oldstress) < reltols * newstress && break
        abs(newstress - oldstress) < abstols && break
        norm(X - X0) < abstolx && break
        X0 = X
    end
    if itcounter == maxiter 
        @warn "Maximum number of iterations reached without convergence"
    end
    returnall ? (Xs, stresses) : Xs[end]
end

"""
Stress function to majorize

Input:
    X: A particular layout (coordinates in rows)
    d: Matrix of pairwise distances
    w: Weights for each pairwise distance

See (1) of Reference
"""
function stress(X, d = fill(1.0, size(X, 1), size(X, 1)), w = nothing)
    s = 0.0
    n = size(X, 1)
    if w == nothing
        w = d .^ -2
        w[.!isfinite.(w)] = 0
    end
    @assert n == size(d, 1) == size(d, 2) == size(w, 1) == size(w, 2)
    for j = 1:n, i = 1:j-1
        s += w[i, j] * (norm(X[i, :] - X[j, :]) - d[i, j])^2
    end
    @assert isfinite.(s)
    s
end

function _checksquare(M::Matrix)
    r, c = size(M)
    return r
end
"""
Compute weighted Laplacian given ideal weights w

Lʷ defined in (4) of the Reference
"""
function weightedlaplacian(w)
    n = _checksquare(w)
    T = eltype(w)
    Lw = zeros(T, n, n)
    for i = 1:n
        D = zero(T)
        for j = 1:n
            i == j && continue
            Lw[i, j] = -w[i, j]
            D += w[i, j]
        end
        Lw[i, i] = D
    end
    Lw
end

"""
Computes L^Z defined in (5) of the Reference

Input: Z: current layout (coordinates)
       d: Ideal distances (default: all 1)
       w: weights (default: d.^-2)
"""
function LZ(Z, d, w)
    n = size(Z, 1)
    L = zeros(n, n)
    for i = 1:n
        D = 0.0
        for j = 1:n
            i == j && continue
            nrmz = norm(Z[i, :] - Z[j, :])
            nrmz == 0 && continue
            δ = w[i, j] * d[i, j]
            L[i, j] = -δ / nrmz
            D -= -δ / nrmz
        end
        L[i, i] = D
    end
    @assert all(isfinite.(L))
    L
end




function private_dist(G::SimpleGraph)
    n = NV(G)
    d = dist(G)

    A = zeros(n, n)
    vv = vlist(G)

    for i = 1:n
        u = vv[i]
        for j = 1:n
            w = vv[j]
            A[i, j] = d[u, w]
            if A[i, j] < 0
                A[i, j] = n / 2  # should be enough to separate the comps
            end
        end
    end


    return A, vv
end



function _stress(G::SimpleGraph{T}) where T 
    n = NV(G)
    A, vv = private_dist(G)

    currentxy = zeros(n, 2)
    xy = getxy(G)
    for i = 1:n
        v = vv[i]
        currentxy[i, :] = xy[v]
    end

    xy = my_layout_stressmajorize_adj(A, 2, nothing, currentxy)

    d = Dict{T,Vector{Float64}}()
    for i = 1:n
        v = vv[i]
        d[v] = collect(xy[i, :])
    end
    return d
end