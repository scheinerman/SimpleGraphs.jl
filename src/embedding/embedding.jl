
using LinearAlgebra, Statistics

export embed



export transform, scale, rotate, translate, recenter
export edge_length, ensure_embed

const DEFAULT_MARKER_SIZE = 6

# A graph embedding includes these items in the graphs' cache:
# :xy           a dictionary from vertices of [x,y] coordinates
# :vcolor       a dictionay from vertices to color specifications (default all :white)
# :vsize        marker size for vertices  (default: DEFAULT_MARKER_SIZE)
# :line_color   color to draw edges and boundaries of vertices (default :black)



"""
`_new_embed(G)` sets the graph up with a default embedding.

* :vcolor is set to :white for all vertices
* :line_color is set to :black 
* :vsize is set to DEFAULT_MARKER_SIZE 
* :xy is set to a circular embedding 
"""
function _new_embed(G::SimpleGraph{T}) where {T}
    cache_save(G, :vsize, DEFAULT_MARKER_SIZE)

    G.cache[:vcolor] = Dict{T,Any}()
    for v in G.V
        G.cache[:vcolor][v] = :white
    end

    cache_save(G, :line_color, :black)
    n = NV(G)

    G.cache[:xy] = _circular_xy(G)

    nothing
end

"""
`ensure_embed(G)` gives `G` a default embedding if it 
doesn't already have an embedding.
"""
function ensure_embed(G::SimpleGraph)
    if !cache_check(G, :xy)
        _new_embed(G)
    end
end


function private_adj(G::SimpleGraph)
    n = NV(G)
    A = zeros(Int, n, n)
    vv = vlist(G)
    for i = 1:n-1
        u = vv[i]
        for j = (i+1):n
            w = vv[j]
            if has(G, u, w)
                A[i, j] = 1
                A[j, i] = 1
            end
        end
    end
    return A, vv
end




"""
`embed(G)` creates a new embedding for `G`. The full call is
```
embed(G,algorithm;args...)
```
The `symbol` algorithm indicates the embedding algorithm.
The `args` are a collection of possible arguments to be sent
to the algorithm.

The `algorithm` defaults to `:circular` and may be one of the following:

* `:circular`: arrange the vertices evenly in a circle.
* `:random`: arrange the vertices randomly.
* `:spring`: use the `spring` layout from `GraphLayout`. Optional argument:
  * `iterations`.
* `:stress`: use the `stress` layout from `GraphLayout`.
* `:spectral`: use the `spectral` embedding. Optional arguments:
  * `xcol` -- which eigenvalue to use for the `x` coordinate.
  * `ycol` -- which eigenvalue to use for the `y` coordinate
* `:tutte` -- create a Tutte embedding using a longest face (assuming the graph has a rotation system)
  * `outside` [optional] -- a list of vertices to be the outer face of the embedding

Note that if the graph already has (say) an embedding, that embedding may
be used as the starting point for one of the algorithms.
"""
function embed(G::SimpleGraph, algorithm::Symbol = :circular; args...)
    arg_dict = list2dict(collect(args))
    n = NV(G)
    m = NE(G)

    ## FULL LIST OF POSSIBLE ARGUMENTS PRE-PARSED HERE

    verbose::Bool = true
    if haskey(arg_dict, :verbose)
        verbose = arg_dict[:verbose]
    end

    iterations::Int = 0
    if haskey(arg_dict, :iterations) && arg_dict[:iterations] > 0
        iterations = arg_dict[:iterations]
    end

    tolerance = 0.001
    if haskey(arg_dict, :tolerance) && arg_dict[:tolerance] > 0
        tolerance = arg_dict[:tolerance]
    end

    xcol::Int = 2
    if haskey(arg_dict, :xcol) && arg_dict[:xcol] > 0
        xcol = arg_dict[:xcol]
    end

    ycol::Int = 3
    if haskey(arg_dict, :ycol) && arg_dict[:ycol] > 0
        xcol = arg_dict[:ycol]
    end

    # See if there already is an xy-embedding   
    if !cache_check(G, :xy)
        _new_embed(G)
        if algorithm == :circular # no need to do it again 
            return nothing
        end
    end

    if algorithm == :circular
        G.cache[:xy] = _circular_xy(G)
        return nothing
    end

    if algorithm == :random
        G.cache[:xy] = _random_xy(G)
        return nothing
    end

    if algorithm == :spring
        if n < 3 || m == 0
            embed(G)
            return
        end
        if iterations <= 0
            G.cache[:xy] = _spring(G)
        else
            G.cache[:xy] = _spring(G, iterations)
        end
        return nothing
    end

    if algorithm == :stress
        if n < 3 || m == 0
            embed(G)
            return
        end
        G.cache[:xy] = _stress(G)
        return nothing
    end

    if algorithm == :combined
        if n < 3 || m == 0
            embed(G)
            return
        end
        embed(G, :spring, iterations = iterations)
        scale(G)
        embed(G, :stress)
        return nothing
    end


    if algorithm == :spectral
        _spectral(G, xcol, ycol)
        return nothing
    end

    if algorithm == :tutte
        if haskey(args, :outside)
            _tutte(G, args[:outside])
        else
            _tutte(G)
        end
        return nothing
    end

    @warn "Unknown embedding algorithm; no action taken"
    return nothing
end


"""
`embed(G,d)` specifies an embedding of the graph `G` with
a dictionary `d` that maps vertices to coordinates (as two
dimensional vectors `[x,y]`).
"""
function embed(G::SimpleGraph, xy::Dict)
    ensure_embed(G)
    G.cache[:xy] = deepcopy(xy)
    nothing
end



"""
`list2dict(list)` takes a list of `(Symbol,Any)` pairs and
converts them to a dictionary mapping the symbols to their
associated values.
"""
function list2dict(list::Vector)
    d = Dict{Symbol,Any}()
    for it in list
        x, y = it
        d[x] = y
    end
    return d
end


"""
`_circular_xy(G)` creates a standard circular embedding.
"""
function _circular_xy(G::SimpleGraph{T})::Dict where {T}
    n = NV(G)
    xy = Dict{T,Vector{Float64}}()
    if n == 0
        return xy
    end

    r = sqrt(n)
    VV = vlist(G)
    theta = 2 * pi / n
    for k = 1:n
        t = (k - 1) * theta
        x = r * sin(t)
        y = r * cos(t)
        v = VV[k]
        xy[v] = [x, y]
    end
    return xy
end

"""
`_random_xy(G)` creates a random xy-embedding for `G`
"""
function _random_xy(G::SimpleGraph{T})::Dict where {T}
    rootn = sqrt(NV(G))
    xy = Dict{T,Vector{Float64}}()
    for v in G.V
        xy[v] = [rand(), rand()] * rootn
    end
    _recenter(xy)
    return xy
end




"""
`edge_length(G)` returns an array containing the
lengths of the edges in the current embedding of `G`.
"""
edge_length(G::SimpleGraph) = [edge_length(G, ee) for ee in G.E]

"""
`edge_length(G,e)` gives the distance between the
embedded endpoints of the edge `e` in the drawing `G`.
"""
function edge_length(G::SimpleGraph{T}, v, w) where {T}
    p1 = getxy(G, v)
    p2 = getxy(G, w)
    return norm(p1 - p2)
end
edge_length(G::SimpleGraph, ee) = edge_length(G, ee[1], ee[2])


"""
`scale(G,m)` multiplies all coordinates in the graph's drawing by
`m`. If `m` is omitted, the drawing is rescaled so that the average
length of an edge equals 1.
"""
function scale(G::SimpleGraph, m::T) where {T<:Real}
    ensure_embed(G)
    _scale(G.cache[:xy], m)
end

function scale(G::SimpleGraph)
    if NE(G) == 0
        return
    end
    L = mean(edge_length(G))
    if L != 0
        _scale(G.cache[:xy], 1 / L)
    else
        @warn "Cannot scale $G"
    end
    nothing
end






include("transforms.jl")
include("getset.jl")
include("tutte.jl")
include("my_spring.jl")
include("my_stress.jl")
include("colorize.jl")
include("graffle.jl")
include("spectral.jl")
# include("geogebra.jl")
include("tikz.jl")
