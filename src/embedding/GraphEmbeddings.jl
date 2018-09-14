
using LinearAlgebra, Statistics

export embed, remove_embedding, has_embedding
export set_fill_color, set_line_color, get_fill_color, get_line_color


export GraphEmbedding, show
# export draw, draw_labels, unclip

export transform, scale, rotate, translate, recenter
export getxy
export set_vertex_size, get_vertex_size
export edge_length

const DEFAULT_MARKER_SIZE = 10
MARKER_SIZE = DEFAULT_MARKER_SIZE


"""
`GraphEmbedding(G)` creates a drawing of the `SimpleGraph` `G`. It
is given a circular embedding.

**Note**: Direct usage of `GraphEmbedding` is **deprecated**!

`GraphEmbedding(G,d)` creates a drawing using the `Dict` `d` to
specify the vertex locations. `d` should map vertices of `G` to
`Vector`s that specify x,y-coordinates.
"""
mutable struct GraphEmbedding
    G::SimpleGraph
    xy::Dict{Any,Vector{Float64}}
    line_color::String
    fill_color::String
    vertex_size::Int


    function GraphEmbedding(GG::SimpleGraph)
        d = circular_embedding(GG)
        new(GG,d,"black","white",DEFAULT_MARKER_SIZE)
    end

    function GraphEmbedding(GG::SimpleGraph,d::Dict)
        T = vertex_type(GG)
        dd = Dict{T,Vector{Float64}}()

        try
            for v in GG.V
                dd[v] = d[v]
            end
        catch
            error("Dictionary doesn't include all vertices")
        end
        new(GG,dd,"black","white", DEFAULT_MARKER_SIZE)
    end
end


"""
`remove_embedding(G)` erases the graph's embedding saved in its cache.
"""
function remove_embedding(G::SimpleGraph)
  cache_clear(G,:GraphEmbedding)
  nothing
end

"""
`has_embedding(G)` returns `true` if an embedding has been created
for `G` in its cache.
"""
function has_embedding(G::SimpleGraph)
  return cache_check(G,:GraphEmbedding)
end

"""
`get_embedding_direct(G)` returns a direct reference to a
graph's embedding. This function is not exposed. Users should
use `cache_recall(G,:GraphEmbedding)` instead to retrieve
a copy of the drawing. If there is not drawing, a default
(circular) drawing is created.
"""
function get_embedding_direct(G::SimpleGraph)
  if !cache_check(G,:GraphEmbedding)
    X = GraphEmbedding(G)
    G.cache[:GraphEmbedding] = X
  end
  return G.cache[:GraphEmbedding]
end

"""
`set_embedding_direct(G,X)` overwrites (or creates) the drawing
`X` in the graph's cache. This non-exposed function should not be
called by the user.
"""
function set_embedding_direct(G::SimpleGraph, X::GraphEmbedding)
  G.cache[:GraphEmbedding] = X
  nothing
end

"""
`set_fill_color(G,color)` sets the color that gets drawn in the
interior of the vertices. (All vertices get the same color.)
"""
function set_fill_color(G::SimpleGraph, color::String="white")
  if !has_embedding(G)
    embed(G)
  end
  G.cache[:GraphEmbedding].fill_color=color
  nothing
end

"""
`get_fill_color(G)` returns the color used to fill in vertices.
See `set_fill_color`.
"""
function get_fill_color(G::SimpleGraph)
  if !has_embedding(G)
    embed(G)
  end
  return G.cache[:GraphEmbedding].fill_color
end

"""
`set_line_color(G,color)` sets the color used to draw edges and
the circles around vertices.
"""
function set_line_color(G::SimpleGraph, color::String="black")
  if !has_embedding(G)
    embed(G)
  end
  G.cache[:GraphEmbedding].line_color = color
  nothing
end

"""
`get_line_color(G)` returns the color used to draw edges and the
circles around vertices. See `set_line_color`.
"""
function get_line_color(G::SimpleGraph)
  if !has_embedding(G)
    embed(G)
  end
  return G.cache[:GraphEmbedding].line_color
end




"""
`list2dict(list)` takes a list of `(Symbol,Any)` pairs and
converts them to a dictionary mapping the symbols to their
associated values.
"""
function list2dict(list::Vector)
  d = Dict{Symbol,Any}()
  for it in list
    x,y = it
    d[x]=y
  end
  return d
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
* `:distxy`: is my inefficient version of `stress`. Optional arguments:
  * `tolerance` -- small positive real number indicating when to stop iterating.
  * `verbose`-- a boolean specifying if verbose output is produced.
* `:spectral`: use the `spectral` embedding. Optional arguments:
  * `xcol` -- which eigenvalue to use for the `x` coordinate.
  * `ycol` -- which eigenvalue to use for the `y` coordinate

Note that if the graph already has (say) an embedding, that embedding may
be used as the starting point for one of the algorithms.
"""
function embed(G::SimpleGraph, algorithm::Symbol=:circular; args...)
  X = get_embedding_direct(G)
  arg_dict = list2dict(collect(args))

  ## FULL LIST OF POSSIBLE ARGUMENTS PRE-PARSED HERE

  verbose::Bool = true
  if haskey(arg_dict,:verbose)
    verbose = arg_dict[:verbose]
  end

  iterations::Int = 0
  if haskey(arg_dict,:iterations) && arg_dict[:iterations]>0
    iterations = arg_dict[:iterations]
  end

  tolerance = 0.001
  if haskey(arg_dict,:tolerance) && arg_dict[:tolerance]>0
    tolerance = arg_dict[:tolerance]
  end

  xcol::Int = 2
  if haskey(arg_dict,:xcol) && arg_dict[:xcol] > 0
    xcol = arg_dict[:xcol]
  end

  ycol::Int = 3
  if haskey(arg_dict,:ycol) && arg_dict[:ycol] > 0
    xcol = arg_dict[:ycol]
  end

  if algorithm == :circular
    circular!(X)
    return nothing
  end

  if algorithm == :random
    random!(X)
    return nothing
  end

  if algorithm == :spring
    if iterations <= 0
      spring!(X)
    else
      spring!(X,iterations)
    end
    return nothing
  end

  if algorithm == :stress
    stress!(X)
    return nothing
  end

  if algorithm == :distxy
    distxy!(X,tolerance,verbose)
    return nothing
  end

  if algorithm == :combined
    embed(G,:spring,iterations = iterations)
    scale(G)
    embed(G,:stress)
    return nothing
  end


  if algorithm == :spectral
    spectral!(X,xcol, ycol)
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
function embed(G::SimpleGraph,d::Dict)
  X = GraphEmbedding(G,d)
  set_embedding_direct(G,X)
  nothing
end





function circular_embedding(G::SimpleGraph{T}) where T
    d = Dict{T, Vector{Float64}}()
    n = NV(G)

    vv = vlist(G)  # vertices as a list

    s = 2*sin(pi/n)

    t = collect(0:n-1)*2*pi/n
    x = map(sin,t)/s
    y = map(cos,t)/s

    for i = 1:n
        v = vv[i]
        d[v] = [x[i],y[i]]
    end
    return d
end


function show(io::IO, X::GraphEmbedding)
    print(io,"Embedding of $(X.G)")
end


"""
`set_vertex_size(G,sz)` sets the size of the circle used
when drawing vertices. The default is `$DEFAULT_MARKER_SIZE`.
See also `get_vertex_size`.
"""
function set_vertex_size(G::SimpleGraph, m::Int = DEFAULT_MARKER_SIZE)
  if m < 1
    error("Vertex size must be nonnegative")
  end
  if !has_embedding(G)
    embed(G)
  end
  G.cache[:GraphEmbedding].vertex_size = m
  nothing
end

"""
`get_vertex_size(G)` returns the size of the circle used when
drawing vertices. See also `set_vertex_size`.
"""
function get_vertex_size(G::SimpleGraph)
  if !has_embedding(G)
    embed(G)
  end
  return G.cache[:GraphEmbedding].vertex_size
end

"""
`circular!(X)` arranges the vertices of the graph held in the
`GraphEmbedding` around a circle.
"""
function circular!(X::GraphEmbedding)
    X.xy = circular_embedding(X.G)
    rescale!(X)
    return
end

function private_adj(X::GraphEmbedding)
    n = NV(X.G)
    A = zeros(Int,n,n)
    vv = vlist(X.G)
    for i=1:n-1
        u = vv[i]
        for j=(i+1):n
            w = vv[j]
            if has(X.G,u,w)
                A[i,j] = 1
                A[j,i] = 1
            end
        end
    end
    return A,vv
end


function private_dist(X::GraphEmbedding)
    n = NV(X.G)
    d = dist(X.G)

    A = zeros(n,n)
    vv = vlist(X.G)

    for i=1:n
        u = vv[i]
        for j=1:n
            w = vv[j]
            A[i,j] = d[u,w]
            if A[i,j] < 0
                A[i,j] = n/2  # should be enough to separate the comps
            end
        end
    end


    return A,vv
end

# TEMPORARILY OFF LINE DURING TRANSITION TO JULIA 0.7

include("my_spring.jl")

"""
`spring!(X)` gives the graph held in `X` with a spring embedding
(based on code in the `GraphLayout` module). If runs a default number of
iterations (100) of that algorithm. To change the number of
iterations, use `spring!(X,nits)`.
"""
function spring!(X::GraphEmbedding, nits::Int=100)
    n = NV(X.G)
    A,vv = private_adj(X)

    x,y = layout_spring_adj(A,MAXITER=nits)

    d = Dict{vertex_type(X.G), Vector{Float64}}()
    for i = 1:n
        v = vv[i]
        d[v] = [x[i], y[i]]
    end
    X.xy = d
    return
end

include("my_stress.jl")

"""
`stress!(X)` computes a stress major layout using code taken from the
`GraphLayout` package.
"""
function stress!(X::GraphEmbedding)
    n = NV(X.G)
    A,vv = private_dist(X)

    currentxy = zeros(n,2)
    for i=1:n
        v = vv[i]
        currentxy[i,:] = X.xy[v]
    end

    xy = my_layout_stressmajorize_adj(A,2,nothing,currentxy)

    d = Dict{vertex_type(X.G), Vector{Float64}}()
    for i = 1:n
        v = vv[i]
        d[v] = collect(xy[i,:])
    end
    X.xy = d
    return
end


"""
`random!(X)` gives the graph held in `X` a random embedding.
"""
function random!(X::GraphEmbedding)
    rootn = sqrt(NV(X.G))
    for v in X.G.V
        X.xy[v] = [rand(), rand()]*rootn
    end
    recenter!(X)
end


function transform!(X::GraphEmbedding,
                    A::Array{S,2},
                    b::Vector{T}) where {S<:Real,T<:Real}

    # apply the transformation x |--> Ax+b to all coordinates
    for k in keys(X.xy)
        X.xy[k] = A*X.xy[k] + b
    end
    nothing
end

"""
`transform(G,A,b)` applies an affine transformation to all coordinates
in the graph's drawing. Here `A` is 2-by-2 matrix and `b` is a 2-vector.
Each point `p` is mapped to `A*p+b`.
"""
function transform(G::SimpleGraph,
                    A::Array{S,2},
                    b::Vector{T}) where {S<:Real, T<:Real}
  X = get_embedding_direct(G)
  transform!(X,A,b)
end


function rescale!(X::GraphEmbedding, m::T) where T<:Real
    A = zeros(T,2,2)
    A[1,1] = m
    A[2,2] = m
    b = zeros(T,2)
    transform!(X,A,b)
end

function rescale!(X::GraphEmbedding)
    L = mean(edge_length(X))
    if L != 0
        rescale!(X,1/L)
    else
      @warn "Cannot scale by 0. No action taken."
    end
    nothing
end


"""
`scale(G,m)` multiplies all coordinates in the graph's drawing by
`m`. If `m` is omitted, the drawing is rescaled so that the average
length of an edge equals 1.
"""
function scale(G::SimpleGraph, m::T) where T<:Real
  X = get_embedding_direct(G)
  rescale!(X,m)
end

function scale(G::SimpleGraph)
  X = get_embedding_direct(G)
  rescale!(X)
end



function rotate!(X::GraphEmbedding, theta)
    A = zeros(Float64,2,2)
    A[1,1] = cos(theta)
    A[1,2] = -sin(theta)
    A[2,1] = sin(theta)
    A[2,2] = cos(theta)
    b = zeros(Float64,2)
    transform!(X,A,b)
    return
end

"""
`rotate(G,theta)` rotate's the graph's drawing by the angle
`theta`.
"""
rotate(G::SimpleGraph, theta::T) where T<:Real = rotate!(get_embedding_direct(G),theta)


function translate!(X::GraphEmbedding, b::Vector{T}) where T
    #A = eye(T,2)
    A = Matrix{T}(I,2,2)
    transform!(X,A,b)
    return
end

"""
`translate(G,b)` translates the graph's drawing by the vector `b`;
that is, every point `p` in the drawing is replaced by `p+b`.
"""
translate(G::SimpleGraph, b::Vector{T}) where T<:Real = translate!(get_embedding_direct(G),b)


function recenter!(X::GraphEmbedding)
    b = [0;0]

    for v in X.G.V
        b += X.xy[v]
    end
    b /= NV(X.G)
    translate!(X,-b)
end

"""
`recenter(G)` translates the graph's drawing so that the center of mass
of the vertices is at the origin.
"""
recenter(G::SimpleGraph) = recenter!(get_embedding_direct(G))


"""
`draw_labels(G)` will add the vertices names to the drawing
window.

The results are usually ugly. One can try increasing the size of the
vertices (see `set_vertex_size`). The font size of the labels can be
specified using `draw_labels(G,FontSize)`. The default is 10.
"""
function draw_labels(G::SimpleGraph, FontSize::Int=10)
  X = get_embedding_direct(G)
  draw_labels(X,FontSize)
  nothing
end


function draw_labels(X::GraphEmbedding, FontSize::Int)
    for v in X.G.V
        x,y = X.xy[v]
        text(x,y,string(v),fontsize=FontSize)
    end
end


"""
`getxy(G)` returns a copy of the dictionary mapping vertices to their
x,y-coordinates. This is a way of saving an embedding.
"""
getxy(G::SimpleGraph) = deepcopy(get_embedding_direct(G).xy)

"""
`edge_length(X::GraphEmbedding,e)` gives the distance between the
embedded endpoints of the edge `e` in the drawing `X`
"""
function edge_length(X::GraphEmbedding, e)
    p1 = X.xy[e[1]]
    p2 = X.xy[e[2]]
    return norm(p1-p2)
end

"""
`edge_length(X::GraphEmbedding)` returns an array containing the
lengths of the edges in this drawing.
"""
function edge_length(X::GraphEmbedding)
    EE = elist(X.G)

    return [ edge_length(X,e) for e in EE ]
end


#include("distxy.jl") # distxy! has been replaced by stress!
include("graffle.jl")
include("spectral.jl")
include("geogebra.jl")
include("embedded-graphs.jl")
