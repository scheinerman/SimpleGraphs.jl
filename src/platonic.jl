export Tetrahedron, Dodecahedron, Icosahedron, Octahedron

function add_edge_matrix!(G::SimpleGraph, edges::Array{Int,2})
    ne = size(edges,1)
    for j=1:ne
        e = edges[j,:]
        add!(G,e[1],e[2])
    end
    return
end

"""
`Tetrahedron()` creates the tetrahedron `SimpleGraph`.
"""
Tetrahedron() = Complete(4)

"""
`Dodecahedron()` creates the dodecahedron `SimpleGraph`.
"""
function Dodecahedron()
    G = IntGraph()
    edges = [
             1 2
             1 11
             1 20
             2 3
             2 9
             3 4
             3 7
             4 5
             4 20
             5 6
             5 18
             6 7
             6 16
             7 8
             8 9
             8 15
             9 10
             10 11
             10 14
             11 12
             12 13
             12 19
             13 14
             13 17
             14 15
             15 16
             16 17
             17 18
             18 19
             19 20
             ]
    add_edge_matrix!(G,edges)
    name(G,"Dodecahedron graph")
    return G
end

"""
`Icosahedron()` creates the icosahedron `SimpleGraph`.
"""
function Icosahedron()
    G = IntGraph()
    edges = [
             1 2
             1 6
             1 8
             1 9
             1 12
             2 3
             2 6
             2 7
             2 9
             3 4
             3 7
             3 9
             3 10
             4 5
             4 7
             4 10
             4 11
             5 6
             5 7
             5 11
             5 12
             6 7
             6 12
             8 9
             8 10
             8 11
             8 12
             9 10
             10 11
             11 12
             ]
    add_edge_matrix!(G, edges)
    name(G,"Icosahedron graph")
    return G
end

"""
`Octahedron()` creates the octaahedron `SimpleGraph`.
"""
function Octahedron()
    G = Complete([2,2,2])
    name(G,"Octahedron graph")
    return G
end
