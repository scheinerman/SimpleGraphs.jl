# functions for building various standard types of graphs

export Complete, Path, Cycle, RandomGraph, RandomRegular, RandomSBM
export RandomTree, code_to_tree
export Grid, Wheel, Cube, BuckyBall, Johnson, Doyle
export Petersen,
    Kneser,
    Paley,
    Knight,
    Frucht,
    Hoffman,
    HoffmanSingleton,
    Spindle,
    Golomb,
    is_unit_distance

"""
`Complete(n)` returns a complete graph with `n` vertices `1:n`.

`Complete(n,m)` returns a complete bipartite graph with `n` vertices
in one part and `m` vertices in the other.

`Complete([n1,n2,...,nt])` returns a complete multipartite graph with
parts of size `n1`, `n2`, ..., `nt`.
"""
function Complete(n::Int)
    G = IntGraph(n)

    for k = 1:n-1
        for j = k+1:n
            add!(G, j, k)
        end
    end
    name(G, "Complete")
    return G
end

# Create a complete bipartite graph
function Complete(n::Int, m::Int)
    G = IntGraph(n + m)
    for u = 1:n
        for v = n+1:n+m
            add!(G, u, v)
        end
    end
    name(G, "Complete($n,$m)")
    return G
end

# Create the complete multipartite graph with given part sizes
function Complete(parts::Array{Int,1})
    # check all part sizes are positive
    for p in parts
        if p < 1
            error("All part sizes must be positive")
        end
    end

    n = sum(parts)
    G = IntGraph(n)

    np = length(parts)
    if np < 2
        return G
    end

    # create table of part ranges
    ranges = Array{Int}(undef, np, 2)   # old ranges = Array(Int,np,2)
    ranges[1, 1] = 1
    ranges[1, 2] = parts[1]
    for k = 2:np
        ranges[k, 1] = ranges[k-1, 2] + 1
        ranges[k, 2] = ranges[k, 1] + parts[k] - 1
    end

    # Add all edges between all parts
    for i = 1:np-1
        for j = i+1:np
            for u = ranges[i, 1]:ranges[i, 2]
                for v = ranges[j, 1]:ranges[j, 2]
                    add!(G, u, v)
                end
            end
        end
    end
    name(G, "Complete($parts)")
    return G
end



# Create a path graph on n vertices
"""
`Path(n)` creates a path graph with `n` vertices named `1:n`.

`Path(array)` creates a path graph with vertices `array[1]`,
`array[2]`, etc.
"""
function Path(n::Int)
    G = IntGraph(n)
    for v = 1:n-1
        add!(G, v, v + 1)
    end
    name(G, "Path")
    set_rot(G)
    d = Dict{Int,Vector{Float64}}()
    for v = 1:n
        d[v] = [v - n / 2, 0]
    end
    embed(G, d)
    return G
end

# Create a path graph from a list of vertices
function Path(verts::Array{T}) where {T}
    G = UndirectedGraph{T}()
    n = length(verts)

    if n == 1
        add!(G, verts[1])
    end
    for k = 1:n-1
        add!(G, verts[k], verts[k+1])
    end
    name(G, "Path")
    set_rot(G)
    return G
end

# Create a cycle graph on n vertices
"""
`Cycle(n)` creates a cycle with vertex set `1:n`.
"""
function Cycle(n::Int)
    if n < 3
        error("Cycle requires 3 or more vertices")
    end
    G = Path(n)
    add!(G, 1, n)
    name(G, "Cycle")
    set_rot(G)
    embed(G)
    return G
end

# Create the wheel graph on n vertices: a cycle on n-1 vertices plus
# an additional vertex adjacent to all the vertices on the wheel.
"""
`Wheel(n)` creates a wheel graph with `n` vertices. That is, a cycle
with `n-1` vertices `1:(n-1)` all adjacent to a common single vertex,
`n`.
"""
function Wheel(n::Int)
    if n < 4
        error("Wheel graphs must have at least 4 vertices")
    end
    G = Cycle(n - 1)
    for k = 1:n-1
        add!(G, k, n)
    end
    name(G, "Wheel")
    embed(G, :tutte, outside = collect(1:n-1))
    embed_rot(G)
    return G
end

# Create a grid graph
"""
`Grid(n,m)` creates an `n`-by-`m` grid graph. For other grids, we
suggest `Path(n1)*Path(n2)*Path(n3)` optionally wrapped in
`relabel`. See also: `Cube`.
"""
function Grid(n::Int, m::Int)
    G = UndirectedGraph{Tuple{Int,Int}}()

    # add the vertices
    for u = 1:n
        for v = 1:m
            add!(G, (u, v))
        end
    end

    #horizontal edges
    for u = 1:n
        for v = 1:m-1
            add!(G, (u, v), (u, v + 1))
        end
    end

    # vertical edges
    for v = 1:m
        for u = 1:n-1
            add!(G, (u, v), (u + 1, v))
        end
    end

    # embedding
    d = Dict{Any,Array{Float64,1}}()
    for v in G.V
        x, y = v
        d[v] = [Float64(x), Float64(y)]
    end
    embed(G, d)
    recenter(G)
    embed_rot(G)

    # make a black-white coloring
    c = Dict{Tuple{Int,Int},Int}()
    for (a, b) ∈ G.V
        c[(a, b)] = mod1(a + b, 2)
    end
    set_vertex_color(G, c, [:white, :black])


    name(G, "Grid($n,$m)")
    return G
end


# Create an Erdos-Renyi random graph
"""
`RandomGraph(n,p=0.5)` creates an Erdos-Renyi random graph with `n`
vertices and edge probability `p`.
"""
function RandomGraph(n::Int, p::Real = 0.5)
    G = IntGraph(n)

    # guess the size of the edge set to preallocate storage
    m = round(Int, n * n * p) + 1

    # generate the edges
    for v = 1:n-1
        for w = v+1:n
            if (rand() < p)
                add!(G, v, w)
            end
        end
    end
    name(G, "Erdos-Renyi, p=$p")
    return G
end

include("prufer.jl")


# Generate a random tree on vertex set 1:n. All n^(n-2) trees are
# equally likely.

"""
`RandomTree(n)` creates a random tree on `n` vertices each with
probability `1/n^(n-2)`.
"""
function RandomTree(n::Int)
    if n < 0   # but we allow n==0 to give empty graph
        error("Number of vertices cannot be negative")
    end

    if n < 2
        return IntGraph(n)
    end

    code = [mod(rand(Int), n) + 1 for _ = 1:n-2]
    G = prufer_restore(code)
    name(G, "Tree")
    return G
end

# # This is a helper function for RandomTree that converts a Prufer code
# # to a tree. No checks are done on the array fed into this function.
# function code_to_tree(code::Array{Int,1})
#     n = length(code) + 2
#     G = IntGraph(n)
#     degree = ones(Int, n)  # initially all 1s

#     #every time a vertex appears in code[], up its degree by 1
#     for c in code
#         degree[c] += 1
#     end

#     for u in code
#         for v = 1:n
#             if degree[v] == 1
#                 add!(G, u, v)
#                 degree[u] -= 1
#                 degree[v] -= 1
#                 break
#             end
#         end
#     end

#     last = findall(x -> x != 0, degree)
#     add!(G, last[1], last[2])

#     return G
# end

# Create the Cube graph with 2^n vertices
"""
`Cube(n)` creates the `n`-dimensional cube graph. This graph has `2^n`
vertices named by all possible length-`n` strings of 0s and 1s. Two
vertices are adjacent iff they differ in exactly one position.
"""
function Cube(n::Integer = 3)
    G = StringGraph()
    for u = 0:2^n-1
        for shift = 0:n-1
            v = xor((1 << shift), u)
            add!(G, string(u, base = 2, pad = n), string(v, base = 2, pad = n))
        end
    end
    name(G, "Cube($n)")

    if n < 3
        set_rot(G)
    end

    if n == 3
        F = ["000", "001", "011", "010"]
        embed(G, :tutte, outside = F)
        embed_rot(G)
    end

    return G
end

# Create the BuckyBall graph

"""
`BuckyBall()` returns the Bucky ball graph.
"""
function BuckyBall()
    G = IntGraph()
    edges = [
        (1, 3),
        (1, 49),
        (1, 60),
        (2, 4),
        (2, 10),
        (2, 59),
        (3, 4),
        (3, 37),
        (4, 18),
        (5, 7),
        (5, 9),
        (5, 13),
        (6, 8),
        (6, 10),
        (6, 17),
        (7, 8),
        (7, 21),
        (8, 22),
        (9, 10),
        (9, 57),
        (11, 12),
        (11, 13),
        (11, 21),
        (12, 28),
        (12, 48),
        (13, 14),
        (14, 47),
        (14, 55),
        (15, 16),
        (15, 17),
        (15, 22),
        (16, 26),
        (16, 42),
        (17, 18),
        (18, 41),
        (19, 20),
        (19, 21),
        (19, 27),
        (20, 22),
        (20, 25),
        (23, 24),
        (23, 32),
        (23, 35),
        (24, 26),
        (24, 39),
        (25, 26),
        (25, 31),
        (27, 28),
        (27, 31),
        (28, 30),
        (29, 30),
        (29, 32),
        (29, 36),
        (30, 45),
        (31, 32),
        (33, 35),
        (33, 40),
        (33, 51),
        (34, 36),
        (34, 46),
        (34, 52),
        (35, 36),
        (37, 38),
        (37, 41),
        (38, 40),
        (38, 53),
        (39, 40),
        (39, 42),
        (41, 42),
        (43, 44),
        (43, 47),
        (43, 56),
        (44, 46),
        (44, 54),
        (45, 46),
        (45, 48),
        (47, 48),
        (49, 50),
        (49, 53),
        (50, 54),
        (50, 58),
        (51, 52),
        (51, 53),
        (52, 54),
        (55, 56),
        (55, 57),
        (56, 58),
        (57, 59),
        (58, 60),
        (59, 60),
    ]
    for e in edges
        add!(G, e[1], e[2])
    end
    name(G, "Buckyball")
    embed(G, :tutte, outside = [15, 16, 42, 41, 18, 17])
    embed_rot(G)
    return G
end

# The Kneser graph Kneser(n,k) has C(n,k) vertices that are the
# k-element subsets of 1:n in which two vertices are adjacent if (as
# sets) they are disjoint. The Petersen graph is Kneser(5,2).

# import IterTools.subsets

"""
`Kneser(n,m)` creates the Kneser graph whose vertices are all the
`m`-element subsets of `1:n` in which two vertices are adjacent iff
they are disjoint.
"""
function Kneser(n::Int, k::Int)
    A = collect(1:n)
    vtcs = [Set(v) for v in IterTools.subsets(A, k)]
    G = UndirectedGraph{Set{Int}}()

    for v in vtcs
        add!(G, v)
    end

    nn = length(vtcs)
    for i = 1:nn-1
        u = vtcs[i]
        for j = i+1:nn
            v = vtcs[j]
            if length(intersect(u, v)) == 0
                add!(G, u, v)
            end
        end
    end
    name(G, "Kneser($n,$k)")
    return G
end


"""
`Johnson(n,k)` creates the Johnson graph whose vertices
and the `k`-element subsets of `{1,2,...,n}`. Vertices `v`
and `w` are adjacent if their intersection has size `k-1`.
"""
function Johnson(n::Int, k::Int)
    if k < 0 || n < 0
        error("n,k must be nonnegative")
    end

    if k > n
        error("k must not be greater than n")
    end

    A = collect(1:n)
    vtcs = [Set{Int}(v) for v in IterTools.subsets(A, k)]
    G = UndirectedGraph{Set{Int}}()

    for v in vtcs
        add!(G, v)

        for j = 1:n
            if !in(j, v)
                for x in v
                    w = deepcopy(v)
                    push!(w, j)
                    pop!(w, x)
                    add!(G, v, w)
                end
            end
        end
    end

    name(G, "Johnson($n,$k)")
    return G
end


# Create the Petersen graph.
"""
`Petersen()` returns the Petersen graph. The vertices are labeled as
the 2-element subsets of `1:5`. Wrap in `relabel` to have vertices
named `1:10`. See also: `Kneser`.
"""
function Petersen()
    G = Kneser(5, 2)
    name(G, "Petersen")
    embed(G, _pete_embed())
    embed_rot(G)
    return G
end

"""
    _pete_embed
Create a nice embedding for the `Petersen` graph.
"""
function _pete_embed()
    d = Dict{Set{Int},Vector{Float64}}()
    θ = 2π / 5

    r1 = 2.5
    r2 = 1.0

    ring1 = [Set([1, 4]), Set([3, 5]), Set([2, 4]), Set([1, 3]), Set([2, 5])]
    ring2 = [Set([2, 3]), Set([1, 2]), Set([1, 5]), Set([4, 5]), Set([3, 4])]

    for k = 0:4
        v = ring1[k+1]
        w = ring2[k+1]
        α = k * θ
        x = sin(α)
        y = cos(α)
        d[v] = r1 * [x, y]
        d[w] = r2 * [x, y]
    end

    return d

end



# Create Paley graphs

"""
`Paley(p)` creates the Paley graph with `p` vertices named
`0:(p-1)`. Here `p` must be a prime with `p%4==1`. Vertices `u` and
`v` are adjacent iff `u-v` is a quadratic residue (perfect square)
modulo `p`.
"""
function Paley(p::Int)
    if mod(p, 4) != 1 || ~isprime(p)
        error("p must be a prime congruent to 1 mod 4")
    end

    # Quadratic residues mod p
    qrlist = unique([mod(k * k, p) for k = 1:p])

    G = IntGraph()
    for u = 0:p-1
        for k in qrlist
            v = mod(u + k, p)
            add!(G, u, v)
        end
    end
    name(G, "Paley")
    return G
end

"""
`Frucht()` returns the Frucht graph: A 12-vertex, 3-regular
graph with no non-nontrivial automorphisms.
"""
function Frucht()
    G = Cycle(12)
    more_edges = [(1, 6), (2, 4), (3, 11), (5, 7), (8, 10), (9, 12)]
    add_edges!(G, more_edges)
    F = [3, 11, 10, 8, 7, 5, 4]
    embed(G, :tutte, outside = F)
    embed_rot(G)
    name(G, "Frucht")
    return G
end

# Called by RandomRegular ... one step
function RandomRegularBuilder(n::Int, d::Int)
    # caller has already checked the values of n,d are legit
    vlist = randperm(n * d)
    G = IntGraph(n * d)
    for v = 1:2:n*d
        add!(G, vlist[v], vlist[v+1])
    end

    for v = n:-1:1
        mushlist = collect(d*(v-1)+1:v*d)
        for k = d-1:-1:1
            contract!(G, mushlist[k], mushlist[k+1])
        end
    end
    return relabel(G)
end

"""
`RandomRegular(n,d)` creates a random `d`-regular graph on `n`
vertices. This can take a while especially if the arguments are
large. Call with an optional third argument to activate verbose
progress reports: `RandomRegular(n,p,true)`.
"""
function RandomRegular(n::Int, d::Int, verbose::Bool = false)
    # sanity checks
    if n < 1 || d < 1 || (n * d) % 2 == 1
        error("n,d must be positive integers and n*d even")
    end
    if verbose
        println("Trying to build ", d, "-regular graph on ", n, " vertices")
        count::Int = 0
    end

    while true
        if verbose
            count += 1
            println("Attempt ", count)
            tic()
        end
        g = RandomRegularBuilder(n, d)
        if verbose
            toc()
        end
        dlist = deg(g)
        if dlist[1] == dlist[n]
            if verbose
                println("Success")
            end
            name(g, "Regular, d=$d")
            return g
        end
        if verbose
            println("Failed; trying again")
        end
    end
end



"""
`RandomSBM(bmap,pmat)` creates a random stochastic block model random graph.
The vector `bmap` is a list of `n` positive integers giving the block number
of vertices `1:n`. The `i,j`-entry of the matrix `pmat` gives the probability
of an edge from a vertex in block `i` to a vertex in block `j`.

`RandomSBM(n,pvec,pmat)` creates such a graph with `n` vertices. The vector
`pvec` gives the probabilities that vertices fall into a given block.
"""
function RandomSBM(bmap::Vector{Int}, pmat::Array{S,2}) where {S<:Real}
    n = length(bmap)    # no of vertices
    b = maximum(bmap)   # no of blocks

    @assert minimum(bmap) > 0 "Block numbers must be positive"
    @assert pmat == pmat' "Probability matrix must be square and symmetrical"
    r = size(pmat, 1)
    @assert b <= r "Insufficient rows/cols in probability matrix"
    @assert minimum(pmat) >= 0 && maximum(pmat) <= 1 "Entries in probability matrix out of range"

    G = IntGraph(n)
    for u = 1:n-1
        bu = bmap[u]
        for v = u+1:n
            bv = bmap[v]
            p = pmat[bu, bv]
            if rand() <= p
                add!(G, u, v)
            end
        end
    end
    name(G, "Stochastic Block Model")
    return G
end


function RandomSBM(n::Int, pvec::Vector{S}, pmat::Array{T,2}) where {S<:Real,T<:Real}
    @assert minimum(pvec) >= 0 "Entries in pvec must be nonnegative"
    @assert sum(pvec) == 1 "Entries in pvec must sum to 1"
    bmap = [random_choice(pvec) for _ = 1:n]
    return RandomSBM(bmap, pmat)
end





"""
`Knight(r::Int=8,c::Int=8)` creates a Knight's Moves graph on a
`r`-by-`c` grid. That is, the vertices of this graph are the squares
of an `r`-by-`c` chess board. Two vertices are adjacent if a Knight
can go from one of these squares to the other in a single move.
"""
function Knight(r::Int = 8, c::Int = 8)
    vtcs = collect(Base.Iterators.product(1:r, 1:c))
    G = UndirectedGraph{Tuple{Int64,Int64}}()
    d = Dict{Tuple{Int,Int},Vector{Float64}}()

    for v in vtcs
        add!(G, v)
        d[v] = collect(v)
    end

    for v in vtcs
        for w in vtcs
            xv = collect(v)
            xw = collect(w)
            z = sort(map(abs, xv - xw))
            if z == [1, 2]
                add!(G, v, w)
            end
        end
    end
    name(G, "Knight($r,$c)")
    embed(G, d)

    # make a black-white coloring
    c = Dict{Tuple{Int,Int},Int}()
    for (a, b) ∈ G.V
        c[(a, b)] = mod1(a + b, 2)
    end
    set_vertex_color(G, c, [:white, :black])

    return G
end



"""
`HoffmanSingleton()` creates the Hoffman-Singleton graph. This is
a 7-regular graph whose diameter is 2 and whose girth is 5.
"""
function HoffmanSingleton()
    G = StringGraph()
    # P-pentagons
    for i = 0:4
        for j = 0:4
            jj = mod(j + 1, 5)
            v = "P$i$j"
            w = "P$i$jj"
            add!(G, v, w)
        end
    end

    # Q-pentagrams
    for i = 0:4
        for j = 0:4
            jj = mod(j + 2, 5)
            v = "Q$i$j"
            w = "Q$i$jj"
            add!(G, v, w)
        end
    end

    # Connections
    for i = 0:4
        for j = 0:4
            for k = 0:4
                v = "P$i$j"
                x = mod(i * k + j, 5)
                w = "Q$k$x"
                add!(G, v, w)
            end
        end
    end
    name(G, "Hoffman-Singleton")
    return G
end

"""
`Hoffman()` creates the Hoffman graph which is cospectral with,
but not isomorphic to, `Cube(4)`.
"""
function Hoffman()
    D = [
        1 1 1 1 0 0 0 0
        1 1 1 0 1 0 0 0
        1 0 0 1 0 1 1 0
        0 1 0 1 0 1 0 1
        0 0 1 1 0 0 1 1
        1 0 0 0 1 1 1 0
        0 1 0 0 1 1 0 1
        0 0 1 0 1 0 1 1
    ]

    A = [0*D D; D' 0*D]

    G = UndirectedGraph(A)
    name(G, "Hoffman")
    return G
end




"""
`Doyle()` creates the Doyle/Holt graph.
See article on [Mathworld](http://mathworld.wolfram.com/DoyleGraph.html)
"""
function Doyle()
    T = Tuple{Int,Int}
    G = UndirectedGraph{T}()
    for a = 0:8
        for b = 0:2
            v = (a, b)
            aa = mod(4a + 1, 9)
            bb = mod(b - 1, 3)
            w = (aa, bb)
            add!(G, v, w)
            aa = mod(4a - 1, 9)
            w = (aa, bb)
            add!(G, v, w)
        end
    end
    name(G, "Doyle")
    return G
end


"""
`Spindle()` returns the Moser spindle graph. This is a seven-vertex
unit distance graph with chromatic number equal to 4.
"""
function Spindle()
    G = IntGraph(7)
    edges = [
        (1, 2),
        (1, 3),
        (2, 3),
        (2, 4),
        (3, 4),
        (1, 5),
        (1, 6),
        (5, 6),
        (5, 7),
        (6, 7),
        (4, 7),
    ]
    add_edges!(G, edges)

    # compute a rotation system that's planar
    F = [1, 3, 4, 7, 5]
    embed(G, :tutte, outside = F)
    embed_rot(G)

    # but then give a unit-distance embedding
    d = Dict{Int,Vector}()
    a = sqrt(3) / 2

    pts = [0 1/2 -1/2 0; 0 a a 2a]

    theta = acos(5 / 6) / 2
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)]

    p1 = R * pts
    for k = 1:4
        d[k] = p1[:, k]
    end

    p2 = R' * pts
    for k = 5:7
        d[k] = p2[:, k-3]
    end
    embed(G, d)
    SimpleGraphs.name(G, "Moser Spindle")
    return G
end



"""
    Golomb()
Create the Golomb graph. This is a unit-distance graph with chromatic number 4.
It has 10 vertices and 18 edges.
"""
function Golomb()::UndirectedGraph{Int}
    G = Cycle(6)
    for v = 1:6
        add!(G, 0, v)
    end

    add!(G, 1, 7)
    add!(G, 3, 8)
    add!(G, 5, 9)
    add!(G, 7, 8)
    add!(G, 7, 9)
    add!(G, 8, 9)

    xy = Dict{Int,Vector{Float64}}()

    xy[0] = [0, 0]
    for k = 1:6
        x, y = reim(exp((k - 1) * im * 2 * π / 6))
        xy[k] = [x, y]
    end

    r = sqrt(3) / 3
    θ = acos(r / 2)


    for k = 0:2
        x, y = reim(r * exp((θ + 2 * k * π / 3) * im))
        xy[k+7] = [x, y]
    end

    embed(G, xy)
    name(G, "Golomb")

    return G
end


"""
    is_unit_distance(G, tol=1e-10)
Check to see if the embedded graph `G` is a unit-distance graph. That is, two vertices of `G`
should be distance 1 apart if and only if they are adjacent. The optional `tol` gives some tolerance 
to this assessment to deal with roundoff.
"""
function is_unit_distance(G::UndirectedGraph{T}, tol = 1e-10)::Bool where {T}
    xy = getxy(G)
    VV = vlist(G)
    n = NV(G)
    for i = 1:n-1
        u = VV[i]
        xyu = xy[u]
        for j = u+1:n
            v = VV[j]
            xyv = xy[v]
            unit_check = abs(norm(xyu - xyv) - 1) <= tol

            if has(G, u, v)
                if !unit_check
                    @info "$u and $v are adjacent, but not distance 1 (within tolerance $tol)"
                    return false
                end
            else
                if unit_check
                    @info "$u and $v are not adjacent, but are distance 1 (within tolerance $tol)"
                    return false
                end
            end

        end
    end
    return true

end


export Tutte
"""
    Tutte()::UndirectedGraph{Int}

Return the Tutte graph: a 3-regular, 3-connected, planar, non-Hamiltonian graph.
"""
function Tutte()::UndirectedGraph{Int}
    ee = [
        1 2
        1 9
        2 3
        2 11
        3 4
        4 5
        4 12
        5 6
        5 13
        6 7
        6 15
        7 8
        8 9
        8 15
        9 10
        10 11
        10 14
        11 12
        12 13
        13 14
        14 15
    ]
    G = IntGraph()
    for idx = 1:21
        add!(G, ee[idx, 1], ee[idx, 2])
        add!(G, ee[idx, 1] + 15, ee[idx, 2] + 15)
        add!(G, ee[idx, 1] + 30, ee[idx, 2] + 30)
    end

    add!(G, 3, 16)
    add!(G, 18, 31)
    add!(G, 33, 1)

    add!(G, 46, 7)
    add!(G, 46, 22)
    add!(G, 46, 37)

    outer = [1, 2, 3, 16, 17, 18, 31, 32, 33]
    embed(G, :tutte, outside = outer)
    embed_rot(G)

    name(G, "Tutte")
    return G
end
