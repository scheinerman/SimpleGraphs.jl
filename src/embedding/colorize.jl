export colorize, colorize_hues, bipartite_colorize

"""
`colorize_hues` is a hard-coded list of ten colors used by `colorize`.
"""
const colorize_hues = [:blue, :green, :red, :yellow, :magenta, :cyan, :orange, :pink, :white, :black]

"""
`colorize(G::SimpleGraph{T},d::Dict{T,Int})` assigns colors to the 
vertices of `G` based on the values in `d`. Here, `d` is a dictionary 
mapping the vertices of `G` to integers in the range `1:10`. (This 
would typically be the output of `vertex_color` from the `SimpleGraphAlgorithms`
module.) This function calls `set_vertex_color` for each vertex of `G`.
If `d[v]==k`, then the color assigned to `v` is `colorize_hues[k]`.

This may also be done via `set_vertex_color(G,d)` where `d` is a dictionary 
with values of type `Int`.
"""
function colorize(G::SimpleGraph{T},d::Dict{T,S}) where {T,S<:Integer}
    nh = length(colorize_hues)

    for v in G.V
        idx = d[v]
        if idx <= 0 || idx > nh
            error("Color numbers must be between 1 and $nh; got $idx")
        end
        hue = colorize_hues[idx]
        set_vertex_color(G,v,hue)
    end
end

"""
`bipartite_colorize(G,hue1=:black,hue2=:white)` assigns one of two 
colors to the vertices of `G` according to a bipartition of the graph, or
throws an error if the graph is not bipartite.
"""
function bipartite_colorize(G,hue1=:black, hue2=:white)
    if NV(G) == 0
        return 
    end 
    XY = bipartition(G)
    X = first(parts(XY))
    for v in G.V
        if in(v,X)
            set_vertex_color(G,v,hue1)
        else
            set_vertex_color(G,v,hue2)
        end
    end
    nothing
end
