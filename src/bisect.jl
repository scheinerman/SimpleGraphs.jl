export bisect, cross_edges

"""
`bisect(G::SimpleGraph)` partitions the vertex set of `G` using the
eigenvector associated with the second smallest eigenvalue of the
graph's Laplacian matrix (called `x` below).

This can be invoked as follows:

+ `bisect(G,"user",pivot)` splits the vertices `v` depending on
  `x[v] >= pivot` vs. `x[v] < pivot`.

+ `bisect(G,"zero")` is the same as `bisect(G,"user", 0.0)`.

+ `bisect(G,"median")` is equivalent to `bisect(G,"user",m)` where `m`
  is the median value of `x`.

+ `bisect(G,"equal")` creates a partition in which the two parts have sizes
  the differ by at most 1.

A plain call to `bisect(G)` is equivalent to `bisect(G,"zero")` (which
is the same as `bisect(G,"user", 0.0)`).
"""
function bisect(G::SimpleGraph,
                where::AbstractString="zero",
                pivot::Real=0.0
               )

    verbose = false

    if verbose
        println("G = $G")
        println("where = $where")
        println("pivot = $pivot")
    end

    T = vertex_type(G)
    VV = vlist(G)
    n  = NV(G)
    L  = laplace(G)
    # x  = collect( eig(L)[2][:,2] )
    x = collect( eigen(L).vectors[:,2])

    if verbose
        println(sort(x))
    end

    piv = 0.0


    if where=="equal"
        pairs = sort(collect(zip(x,VV)))
        vtcs  = [ p[2] for p in pairs ]

        if verbose
            println(pairs)
            println(vtcs)
        end

        mid = floor(Int, n/2)
        if verbose
            println("Equal partition of the vertex set: $mid and $(n-mid)")
        end
        A = Set{T}(vtcs[1:mid])
        B = Set{T}(vtcs[mid+1:end])
        return A,B
    end


    if where=="median"
        piv = median(x)
    elseif where=="user"
        piv = pivot
    elseif where=="zero"
        piv = 0.0
    else
        error("Unknown \"where\" specifier: $where")
    end

    if verbose
        println("pivot set to $piv")
    end

    A = Set{T}()
    B = Set{T}()

    for k=1:n
        v = VV[k]
        if x[k] >= piv
            push!(A,v)
        else
            push!(B,v)
        end
    end

    return A,B
end

# import IterTools.product

"""
`cross_edges(G::SimpleGraph,A,B)` returns the set of edges of `G` with
one end in `A` and one end in `B`. Here `A` and `B` are collections
of vertices of `G`.
"""
function cross_edges(G::SimpleGraph, A, B)

    AB = Base.Iterators.product(A,B)

    result = Set(filter(e -> has(G,e[1],e[2]), collect(AB)))
    return result
end
