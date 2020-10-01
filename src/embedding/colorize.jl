export colorize_hues, bipartite_colorize

"""
`colorize_hues` is a hard-coded list of ten colors used by `colorize`.
"""
const colorize_hues = [:blue, :green, :red, :yellow, :magenta, :cyan, :orange, :pink, :white, :black]

"""
This is the code used by `set_vertex_color(G,d,palette)`. Not exported.
"""
function colorize(G::SimpleGraph{T},d::Dict{T,S},palette) where {T,S<:Integer}
    nh = length(palette)

    for v in G.V
        idx = d[v]
        if idx <= 0 || idx > nh
            error("Color numbers must be between 1 and $nh; got $idx")
        end
        hue = palette[idx]
        set_vertex_color(G,v,hue)
    end
end

"""
`bipartite_colorize(G,hue1=:black,hue2=:white)` assigns one of two 
colors to the vertices of `G` according to a bipartition of the graph, or
throws an error if the graph is not bipartite.
"""
function bipartite_colorize(G,hue1=:black, hue2=:white)
    c = two_color(G)
    set_vertex_color(G,c,[hue1,hue2])
end
