export tikz_file, tikz_print

# Code developed by Tara Abrishami

function tikz_string(G::SimpleGraph, label::Bool = false)
    #Outputs a string of tikz code to draw graph G.
    #Label = true if nodes should be labeled in the drawing, false otherwise.
    s = "\\begin{tikzpicture}\n"

    if !has_embedding(G)
        embed(G)
    end

    xy = getxy(G)
    for v in vlist(G)
        x, y = xy[v]
        s *=
            "\\node[draw,circle,minimum size=10,inner sep=0] (" *
            string(v) *
            ") at (" *
            string(x) *
            "," *
            string(y) *
            ")"
        if label
            s *= " {" * string(v) * "}"
        else
            s *= " {}"
        end
        s *= ";\n"
    end
    for ee in elist(G)
        u, v = ee
        s *= "\\draw (" * string(u) * ") -- (" * string(v) * ");\n"
    end
    s *= "\\end{tikzpicture}\n"
    return s
end

"""
`tikz_print(G)` prints tikz code to draw `G`.
`tikz_print(G,true)` does likewise, with vertex labels drawn.
"""
function tikz_print(G::SimpleGraph, label::Bool = false)
    print(tikz_string(G, label))
end

"""
`tikz_file(G,label,filename)` writes the tikz code for drawing the graph `G`
into `filename`. If `label` is omitted (or `false`) vertex labels are not drawn.
If `filename` is omitted, it defaults to `graph.tex`.
"""
function tikz_file(G::SimpleGraph, label::Bool, filename::String = "graph.tex")
    FILE = open(filename, "w")
    print(FILE, tikz_string(G, label))
    close(FILE)
end

tikz_file(G::SimpleGraph, filename::String = "graph.tex") = tikz_file(G, false, filename)
