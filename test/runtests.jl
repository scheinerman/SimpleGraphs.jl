using Test
using SimpleGraphs
using LinearAlgebra
using SparseArrays
using SimplePartitions

# Pkg.clone("https://github.com/scheinerman/SimpleRandom.jl.git")
# Pkg.clone("https://github.com/scheinerman/SimplePartitions.jl.git")
# This is woefully inadequate. Just a placeholder for now.

G = Path(10)
@test NV(G)==10
@test NE(G)==9
@test G[2] == [1,3]
@test deg(G,2) == 2
@test sum(deg(G)) == 2NE(G)
@test diam(G)==9
@test num_components(G) == 1
@test spanning_forest(G) == G
@test is_acyclic(G)

G = Complete(4,4)
@test length(euler(G))==NE(G)+1
@test length(hamiltonian_cycle(G)) == NV(G)
d = two_color(G)
@test length(d) == NV(G)
@test num_parts(bipartition(G)) == 2

G = RandomRegular(10,3)
@test NE(G) == 15
G = Complete([3,3,3])
G = G'
@test NE(G) == 9

G = Paley(17)
@test NE(G) == NE(G')

G = Cycle(10)
delete!(G,1,2)
delete!(G,5,6)
@test !is_connected(G)

G = line_graph(Complete(5))'
H = Petersen()
@test char_poly(G)==char_poly(H)

G = cartesian(Path(5),Path(3))
H = Grid(3,5)
@test girth(G)==4
@test char_poly(G)==char_poly(H)

M = incidence(G)
L = laplace(G)
@test L == M*M'
