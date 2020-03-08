import Base.show, Base.==, Base.adjoint, Base.*
import Base.getindex
import LightXML.name

export SimpleGraph, IntGraph, StringGraph
export show, NV, NE, has, vertex_type, fastN!, name, get_edge
export vlist, elist, neighbors, getindex, deg, deg_hist

"""
The `SimpleGraph` type represents a simple graph; that is, an
undirected graph with no loops and no multiple edges.

Use `SimpleGraph()` to create a new graph in which the vertices may be
`Any` type. Use `SimpleGraph{T}()` to create a new graph in which the
vertices are of type `T`. See `IntGraph` and `StringGraph` as special
cases.
"""
mutable struct SimpleGraph{T} <: AbstractSimpleGraph
    V::Set{T}          # Vertex set
    E::Set{Tuple{T,T}} # Edge set
    N::Dict{T,Set{T}}  # Optional neighbor sets
    Nflag::Bool        # Tells if N is used or not (default on)
    cache::Dict{Symbol,Any}   # save previous expensive results
    cache_flag::Bool          # decide if we use cache or no
    function SimpleGraph{T}(Nflag::Bool=true) where T
        V = Set{T}()
        E = Set{Tuple{T,T}}()
        N = Dict{T,Set{T}}()
        cache = Dict{Symbol,Any}()
        G = new(V,E,N,Nflag,cache,true)
    end
end

"""
`name(G)` returns the graph's name.

`name(G,str)` assigns `str` to be the graph's name. If `str` is
empty, then the name is set to the default `SimpleGraph{T}` where
`T` is the vertex type.
"""
function name(G::SimpleGraph)
  if cache_check(G,:name)
    return cache_recall(G,:name)
  end
  return "SimpleGraph{$(vertex_type(G))}"
end

function name(G::SimpleGraph, the_name::String)
  G.cache[:name] = the_name
  if length(the_name) == 0
    cache_clear(G,:name)
  end
  nothing
end



function show(io::IO, G::SimpleGraph)
    suffix = " (n=$(NV(G)), m=$(NE(G)))"
    print(io,name(G)*suffix)
end

# Default constructor uses Any type vertices
SimpleGraph(Nflag::Bool = true) = SimpleGraph{Any}(Nflag)

# A StringGraph has vertices of type String.
"""
A `StringGraph` is a `SimpleGraph` whose vertices are of type
`String`.

When constructed with `StringGraph()` creates an empty
`SimpleGraph{String}`.

When invoked as `StringGraph(file::AbstractString)` opens the named
file for parsing as a graph. Each line of the file should contain one
or two tokens separated by white space. If the line contains a single
token, we add that token as a vertex. If the line contains two (or
more) tokens, then the first two tokens are taken as vertex names and
(assuming they are different) the corresponding edge is created. Any
extra tokens on the line are ignored. Lines that begin with a # are
ignored.
"""
StringGraph() = SimpleGraph{String}()

function StringGraph(file::AbstractString)
    G = StringGraph()
    load!(G,file)
    return G
end

# Helper function for StrinGraph(file), and can be used to add
# vertices and edges to a graph (assuming its vertex type can
# accomodate strings).
function load!(G::SimpleGraph, file::AbstractString)
    f = open(file, "r")
    while(~eof(f))
        line = chomp(readline(f))
        tokens = split(line)

        if (length(tokens) == 0)
            continue
        end

        if (tokens[1][1] == '#')
            continue
        end

        add!(G,tokens[1])
        if length(tokens) > 1
            add!(G,tokens[1],tokens[2])
        end
    end
end

"""
`IntGraph()` creates a new `SimpleGraph` whose vertices are of type
`Int`. Called as `IntGraph(n::Int)` prepopulates the vertex set with
vertices `1:n`.

`IntGraph(A)` where `A` is an adjacency matrix creates a graph for which
`A` is the adjacency matrix.
"""
IntGraph() = SimpleGraph{Int}()

# With a postive integer argument, adds 1:n as vertex set, but no
# edges.
function IntGraph(n::Int)
    G = IntGraph()
    for v=1:n
        add!(G,v)
    end
    return G
end

function IntGraph(A::AbstractMatrix)
  r,c = size(A)
  @assert r==c "Matrix must be square"
  @assert A==A' "Matrix must be symmetric"
  G = IntGraph(r)
  for i=1:r-1
    for j=i+1:r
      if A[i,j] != 0
        add!(G,i,j)
      end
    end
  end
  return G
end


"""
`SimpleGraph(A)` where `A` is a matrix creates a graph with vertex set
`1:n` where `A` is an `n`-by-`n` symmetric matrix specifying the graph's
adjacency matrix.
"""
SimpleGraph(A::AbstractMatrix) = IntGraph(A)


"""
`vertex_type(G)` returns the data type of the vertices this graph may hold.
For example, if `G=IntGraph()` then this returns `Int64`.`
"""
vertex_type(G::SimpleGraph{T}) where {T} = T

    # number of vertices and edges


"""
`NV(G)` returns the number of vertices in `G`.
"""
NV(G::AbstractSimpleGraph) = length(G.V)

"""
`NE(G)` returns the number of edges in `G`.
"""
NE(G::SimpleGraph) = length(G.E)


"""
`has(G,v)` returns `true` iff `v` is a vertex of `G`.

`has(G,v,w)` returns `true` iff `(v,w)` is an edge of `G`.
"""
has(G::AbstractSimpleGraph, v) = in(v,G.V)
has(G::SimpleGraph, v, w) = in((v,w), G.E) || in((w,v), G.E)


"""
`get_edge(G,u,v)` returns either `(u,v)` or `(v,u)` matching  how
the edge joining `u` and `v` is stored in the edge set of `G`.
An error is thrown if `u` and `v` are not adjacent vertices of `G`.
"""
function get_edge(G::SimpleGraph{T},u,v)::Tuple{T,T} where T
    if !has(G,u,v)
        error("($u,$v) is not an edge of this graph")
    end
    if in((u,v),G.E)
        return u,v
    end
    return v,u
end


# fastN(G,true) creates an additional data structure to speed up
# neighborhood lookups.

"""
`fastN!(G,flg=true)` is used to turn on (or off) fast neighborhood
lookup in graphs. Switching this off decreases the size of the data
structure holding the graph, but slows down look up of edges.

**Note**: Fast neighborhood look up is on by default.
"""
function fastN!(G::SimpleGraph{T},flg::Bool=true) where {T}
    # if no change, do nothing
    if flg == G.Nflag
        return flg
    end

    # if setting the flag to false, erase the G.N data structure;
    # otherwise build it.
    if flg == false
        G.N = Dict{T, Set{T}}()
        sizehint!(G.N, NV(G))
    else
        # build the G.N structure.
        # start with empty sets for each vertex
        for v in G.V
            G.N[v] = Set{T}()
        end
        # now iterate over the edge set and populate G.N sets
        for e in G.E
            v,w = e
            push!(G.N[v],w)
            push!(G.N[w],v)
        end
    end
    G.Nflag = flg
    return flg
end

# Create a mapping between G.V and 1:n. This is not exposed outside
# this module; it's a helper function used by other functions. This
# has been crafted to work with either SimpleGraph or SimpleDigraph
# arguments.
function vertex2idx(G::AbstractSimpleGraph)
    T = vertex_type(G)
    d = Dict{T,Int}()
    V = vlist(G)
    n = NV(G)

    for k=1:n
        d[V[k]] = k
    end

    return d
end

    # get the vertices as a (sorted if possible) list
"""
`vlist(G)` returns the vertices of `G` as a list (array).
"""
function vlist(G::AbstractSimpleGraph)
    result = collect(G.V)
    try
        sort!(result)
    catch
    end
    return result
end

"""
`elist(G)` returns the edges of `G` as a list (array).
"""
function elist(G::SimpleGraph)
    result = collect(G.E)
    try
        sort!(result)
    catch
    end
    return result
end

    # Get the neighbors of a vertex
"""
`neighbors(G,v)` returns a list of the neighbors of `v`.

May also be invoked as `G[v]`.
"""
function neighbors(G::SimpleGraph{T}, v) where {T}
    if ~has(G,v)
        error("Graph does not contain requested vertex")
    end

    if G.Nflag
        N = collect(G.N[v])

    else
        N = T[]
        for w in G.V
            if has(G,v,w)
                append!(N,[w])
            end
        end
    end
    try
        sort!(N)
    catch
    end
    return N
end

# Here is another way to access the neighbors of a vertex: G[v]
getindex(G::SimpleGraph,v) = neighbors(G,v)

# And here's a getindex way to check for edges: G[u,v] is a shortcut
# for has(G,u,v).
getindex(G::SimpleGraph,v,w) = has(G,v,w)

# Degree of a vertex
"""
`deg(G,v)` gives the degree of `v` in `G`.

`deg(G)` gives the degree sequence (sorted).
"""
function deg(G::SimpleGraph, v)
    if ~has(G,v)
        error("Graph does not contain requested vertex")
    end
    if G.Nflag
        return length(G.N[v])
    end
    return length(G[v])
end

# Degree sequence
function deg(G::SimpleGraph{T}) where {T}
    if G.Nflag
        ds = [deg(G,v) for v in G.V]
    else
        dd = Dict{T,Int}()
        for v in G.V
            dd[v] = 0
        end
        for e in G.E
            v,w = e
            dd[v] += 1
            dd[w] += 1
        end
        ds = collect(values(dd))
    end
    sort!(ds, lt = >)
    return ds
end


# Report how many vertices we have each possible degree.
# If G has n vertices, this returns an n-long vector whose
    # k'th entry is the number of vertices of degree k-1.

"""
`deg_hist(G)` gives a tally of how many vertices of each degree are
present in the graph. Because Julia arrays are 1-based, the indexing
is a bit off. Specifically, entry `k` in the returned array is the
number of vertices of degree `k-1`.
"""
function deg_hist(G::SimpleGraph{T}) where {T}
    n = NV(G)
    degs = deg(G)
    result = zeros(Int,n)
    for d in degs
        result[d+1] += 1
    end
    return result
end


import Base.hash

function hash(G::SimpleGraph, h::UInt64 = UInt64(0))
    return hash(G.V,h) + hash(G.E,h)
end
