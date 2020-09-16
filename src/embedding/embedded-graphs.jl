export Spindle

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

    d = Dict{Int,Vector}()
    a = sqrt(3) / 2

    pts = [0 1 / 2 -1 / 2 0; 0 a a 2a]

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
