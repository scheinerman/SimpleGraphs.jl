# The get and set functions pertaining to embeddings

export getxy
export set_vertex_color, set_line_color, get_vertex_color, get_line_color
export set_vertex_size, get_vertex_size


"""
`getxy(G)` returns (a copy of) the `xy`-embedding of `G`.

`getxy(G,v)` returns the `xy`-coordinates of the vertex `v`.
"""
function getxy(G::SimpleGraph)
    ensure_embed(G)
    return(deepcopy(G.cache[:xy]))
end

function getxy(G::SimpleGraph, v)
    ensure_embed(G)
    return G.cache[:xy][v]
end


"""
`get_line_color(G)` returns the color for edges and vertex boundaries
"""
function get_line_color(G::SimpleGraph)
    ensure_embed(G)
    return G.cache[:line_color]
end 

"""
`set_line_color(G::SimpleGraph, hue=:black)` sets the color of the graph's 
edges and vertex boundaries.
"""
function set_line_color(G::SimpleGraph, hue=:black)
    ensure_embed(G)
    G.cache[:line_color] = hue 
end 



"""
`get_vertex_color(G,v)` returns the color assigned to vertex `v`.

`get_vertex_color(G)` returns a copy of the dictionary mapping vertices to colors.
"""
function get_vertex_color(G::SimpleGraph, v)
    ensure_embed(G)
    return G.cache[:vcolor][v]
end 

function get_vertex_color(G::SimpleGraph)
    ensure_embed(G)
    return deepcopy(G.cache[:vcolor])
end


"""
`set_vertex_color(G,v,hue)` sets the color of vertex `v` to `hue`.

`set_vertex_color(G,hue)` sets the color of all vertices to `hue`.
"""
function set_vertex_color(G::SimpleGraph, v, hue)
    ensure_embed(G)
    G.cache[:vcolor][v] = hue 
end 

function set_vertex_color(G::SimpleGraph, hue)
    ensure_embed(G)
    d = G.cache[:vcolor]
    for v in G.V
        d[v] = hue 
    end
end 


function set_vertex_color(G::SimpleGraph, d::Dict{S,T}) where {S,T<:Integer}
    colorize(G,d)
end 

"""
`set_vertex_size(G,s)` sets the radius of the graph's vertices.

`set_vertex_size(G)` restores the radius to the default value.
"""
function set_vertex_size(G::SimpleGraph, s::Int=DEFAULT_MARKER_SIZE)
    ensure_embed(G)
    G.cache[:vsize] = s 
end 

function get_vertex_size(G::SimpleGraph)
    ensure_embed(G)
    return G.cache[:vsize]
end