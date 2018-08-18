# Various simple graph functions associated with graph coloring.

export bipartition, two_color, greedy_color, random_greedy_color

# Create a two-coloring of a graph or die trying. Returns a map from
# the vertex set to the set {1,2}, or error if no such mapping exists.

"""
`two_color(G)` creates a two-coloring of the graph or throws an error
if the graph is not bipartite. The output is a `Dict` mapping the
vertex set to the values 1 and 2.
"""
function two_color(G::SimpleGraph{T}) where {T}
    if cache_check(G,:two_color)
      return cache_recall(G,:two_color)
    end
    f = Dict{T,Int}()
    for A in parts(components(G))
        a = first(A)
        f[a] = 1
        Q = Deque{T}()
        push!(Q,a)
        while length(Q)>0
            v = pop!(Q)
            Nv = G[v]
            for w in Nv
                if haskey(f,w)
                    if f[w]==f[v]
                        error("Graph is not bipartite")
                    end
                else
                    f[w] = 3-f[v]
                    push!(Q,w)
                end
            end
        end
    end
    cache_save(G,:two_color,f)
    return f
end

# Create a bipartition of a graph or die trying. Returns a set {X,Y}
# that is a bipartition of the vertex set of G.

using SimplePartitions
"""
`bipartition(G)` creates a bipartition of the graph (or returns an
error if the graph is not bipartite. Output is a `Partition`.
"""
function bipartition(G::SimpleGraph{T}) where {T}
  f = two_color(G)
  return Partition(f)
end

# Color a graph by the greedy algorithm in the sequence specified by
# seq. The array seq must be a permutation of G.V. We don't check
# that's true!

"""
`greedy_color(G,seq)` creates a greedy proper coloring of the
graph. The argument `seq` should be a 1-dimensional array containing
every vertex exactly once (the function does not check this for
you). The function follows that order in creating the coloring which
is returned to you as a `Dict` mapping vertices to positive integers
(representing the colors).

If `seq` is omitted, a random permutation of the vertices is used.
"""
function greedy_color(G::SimpleGraph{T}, seq::Array{T,1}) where {T}
    f = Dict{T,Int}()  # this is the mapping from V to colors
    maxf::Int = 0      # largest color used

    for v in seq
        colors_used = falses(maxf)  # array if color is used by N[v]
        for w in G[v]
            if haskey(f,w)  # w already colored
                colors_used[f[w]]=true  # mark that color is used
            end
        end
        # give first unused color to v
        for k in 1:maxf
            if colors_used[k] == false
                f[v] = k
                break
            end
        end
        # but if that fails, extend the number of colors available
        if !haskey(f,v)
            maxf += 1
            f[v] = maxf
        end
    end
    return f
end

# This function returns a list of the vertices of G in descending
# order by degree. The order of vertices of the same degree is
# indeterminate. NOTE: This is not exported from this module. Should
# it be?
function deg_sorted_vlist(G::SimpleGraph)
    bye = x -> -x[1]
    list = [ (deg(G,v) , v) for v in G.V ]
    sort!(list, by=bye)
    outlist = [ item[2] for item in list ]
    return outlist
end

# Apply greedy_color to the graph visiting the vertices in decreasing
# order of degree.
function greedy_color(G::SimpleGraph{T}) where {T}
    seq = deg_sorted_vlist(G)
    return greedy_color(G,seq)
end

# Generate multiple random orders of the vertex set and apply
# greedy_color; return one that uses the fewest colors. This do as
# well as or better than greedy_color on some decreasing order of
# degree.

"""
`random_greedy_color(G, reps)` repeatedly invokes `greedy_color` using
random permutations of the vertex set. After `reps` iterations, the
best coloring found is returned.
"""
function random_greedy_color(G::SimpleGraph{T}, reps::Int=1) where {T}
    n = NV(G)
    bestf = greedy_color(G)  # degree order default start
    best  = maximum(values(bestf))
    seq = vlist(G)
    println("Initial coloring uses ", best, " colors")

    for k in 1:reps
        Random.shuffle!(seq)
        f = greedy_color(G,seq)
        mx = maximum(values(f))
        if mx < best
            bestf = f
            best = mx
            println("Reduced to ", best, " colors")
        end
    end
    return bestf
end
