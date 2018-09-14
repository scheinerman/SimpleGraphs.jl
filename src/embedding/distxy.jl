using Optim
export distxy!, demo_distxy

# Grab the 2n coordinates as a single vector
function vector_out(X::GraphEmbedding)
    vv = vlist(X.G)
    n = length(vv)

    x = zeros(2*n)
    for k=1:n
        v = X.xy[vv[k]]
        x[2*k-1] = v[1]
        x[2*k]   = v[2]
    end

    return x
end

# Inverse of vector_out
function vector_in!(X::GraphEmbedding, x::Vector)
    vv = vlist(X.G)
    n = length(vv)

    for k=1:n
        v = vv[k]
        X.xy[v] = x[2*k-1 : 2*k]
    end

    return
end


function distxy!(X::GraphEmbedding,
                 nits::Integer=0, verbose::Bool=true)
    D = dist_matrix(X.G)
    x0 = vector_out(X)

    function score(x::Vector)
        nn = length(x)
        n = NV(X.G)
        s = 0.

        for u=1:(n-1)
            pu = x[2*u-1 : 2*u]
            for v = (u+1):n
                pv = x[2*v-1 : 2*v]
                duv = D[u,v]
                term = (duv - norm(pu-pv))^2 / duv^(1.75)
                s += term
            end
        end
        return s
    end


    if nits > 0
        res = optimize(score,x0,iterations=nits)
    else
        res = optimize(score,x0)
    end


    x1 = res.minimizer
    vector_in!(X,x1)

    if verbose
        msg = "$(res.f_calls) function calls\t" *
          "score = $(score(x1))"
        @info msg
    end

    return score(x1)
end

function distxy!(X::GraphEmbedding,
                 tol::Float64=0.001, verb::Bool=true)
    x0 = Inf
    x1 = 0.0
    # if verb
    #     tic()
    # end
    while true
        x1 = distxy!(X,0,verb)
        if abs(x1-x0)/x0 < tol
            break
        end
        x0 = x1
    end
    # if verb
    #     toc()
    # end
    return x1
end

"""
`demo_distxy(G,tol=1e-3)` presents an animation showing the evolving
drawing found by `distxy!`.
"""
function demo_distxy(G::SimpleGraph=BuckyBall(), tol=1e-3)
    return demo_distxy(GraphEmbedding(G), tol)
end

function demo_distxy(X::GraphEmbedding,tol::Real=1e-3)
    tic()
    x0 = 1.e10
    figure(1)
    while true
        clf()
        draw(X)
        title("Embedding with distxy!")
        x1 = distxy!(X,0)
        if abs(x1-x0)/x0 < tol
            break
        end
        x0 = x1
    end
    title("Finished")
    toc()
    return X
end
