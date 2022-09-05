# The get and set functions pertaining to embeddings

export getxy, hasxy
export set_vertex_color, set_line_color, get_vertex_color, get_line_color
export set_vertex_size, get_vertex_size


"""
`getxy(G)` returns (a copy of) the `xy`-embedding of `G`.

`getxy(G,v)` returns the `xy`-coordinates of the vertex `v`.
"""
function getxy(G::UndirectedGraph)
    ensure_embed(G)
    return (deepcopy(G.cache[:xy]))
end

function getxy(G::UndirectedGraph, v)
    ensure_embed(G)
    return G.cache[:xy][v]
end

"""
`hasxy(G::UndirectedGraph)` returns `true` if an embedding has been 
given to this graph.
"""
hasxy(G::UndirectedGraph)::Bool = cache_check(G, :xy)


"""
`get_line_color(G)` returns the color for edges and vertex boundaries
"""
function get_line_color(G::UndirectedGraph)
    ensure_embed(G)
    return G.cache[:line_color]
end

"""
`set_line_color(G::UndirectedGraph, hue=:black)` sets the color of the graph's 
edges and vertex boundaries.
"""
function set_line_color(G::UndirectedGraph, hue = :black)
    ensure_embed(G)
    G.cache[:line_color] = hue
end



"""
`get_vertex_color(G,v)` returns the color assigned to vertex `v`.

`get_vertex_color(G)` returns a copy of the dictionary mapping vertices to colors.
"""
function get_vertex_color(G::UndirectedGraph, v)
    ensure_embed(G)
    return G.cache[:vcolor][v]
end

function get_vertex_color(G::UndirectedGraph)
    ensure_embed(G)
    return deepcopy(G.cache[:vcolor])
end


"""
`set_vertex_color(G,v,hue)` sets the color of vertex `v` to `hue`.

`set_vertex_color(G,hue)` sets the color of all vertices to `hue`. 
If `hue` is omitted, we use `:white`.
"""
function set_vertex_color(G::UndirectedGraph, v, hue)
    ensure_embed(G)
    G.cache[:vcolor][v] = hue
end

function set_vertex_color(G::UndirectedGraph, hue)
    ensure_embed(G)
    d = G.cache[:vcolor]
    for v in G.V
        d[v] = hue
    end
end

set_vertex_color(G::UndirectedGraph) = set_vertex_color(G, :white)


"""
`set_vertex_color(G::UndirectedGraph, d::Dict, palette)` where `d` is a dictionary 
mapping vertices to integers and `palette` is a list of colors. 

Convert a mapping of vertices to integers into colors for the vertices.

Vertices are assigned colors as follows: vertex `v` gets color `palette[k]`
where `k=d[v]`. If `palette` is omitted, use the constant global variable 
`colorize_hues`.
"""
function set_vertex_color(
    G::UndirectedGraph,
    d::Dict{S,T},
    palette = colorize_hues,
) where {S,T<:Integer}
    colorize(G, d, palette)
end

"""
`set_vertex_size(G,s)` sets the radius of the graph's vertices.

`set_vertex_size(G)` restores the radius to the default value.
"""
function set_vertex_size(G::UndirectedGraph, s::Int = DEFAULT_MARKER_SIZE)
    ensure_embed(G)
    G.cache[:vsize] = s
end

function get_vertex_size(G::UndirectedGraph)
    ensure_embed(G)
    return G.cache[:vsize]
end
