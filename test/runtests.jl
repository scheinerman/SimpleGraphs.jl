using Test
using LinearAlgebra
using SparseArrays
using SimplePartitions
using SimplePolynomials # Polynomials
# using Pkg
# Pkg.add(PackageSpec(name = "SimpleTools", rev = "master"))
# Pkg.resolve()
# using SimpleTools
using SimpleGraphs

@testset "Core" begin
    G = Path(10)
    name(G, "Example")
    @test name(G) == "Example"
    @test NV(G) == 10
    @test NE(G) == 9
    @test G[2] == [1, 3]
    @test deg(G, 2) == 2
    @test sum(deg(G)) == 2NE(G)

    G = IntGraph(2)
    add!(G, 1, 2)
    add!(G, 1, 3)
    add!(G, 2, 3)
    @test NV(G) == NE(G)
    A = adjacency(G)
    H = SimpleGraph(A)
    @test G == H
    H = SimpleGraph(convert(BitMatrix, A))
    @test G == H

    @test get_edge(G, 1, 2) == get_edge(G, 2, 1)

    G = StringGraph()
    add!(G, "alpha", "beta")
    @test G["alpha", "beta"]

    G = SimpleGraph{Complex{Float64}}()
    H = SimpleGraph{Complex{Float64}}()
    add!(G, im, -im)
    add!(H, -im, im)
    @test G == H
end

@testset "Ops" begin
    G = IntGraph(3)
    ee = [(1, 2), (2, 3), (1, 3)]
    add_edges!(G, ee)
    delete!(G, 1, 2)
    @test NE(G) == 2
    G = Cycle(5)
    delete!(G, 5)
    @test G == Path(4)

    G = line_graph(Cycle(5))
    @test deg(G) == 2 * ones(5)

    H = G'
    @test G == H'

    G = Cycle(4)
    H = cartesian(G, G)
    @test NV(H) == NV(G)^2

    H = disjoint_union(Cycle(4), Cycle(5))
    @test NV(H) == 9
    @test NE(H) == 9
    @test H == Cycle(4) + Cycle(5)

    @test 2H == H + H

    G = join(IntGraph(5), IntGraph(4))
    @test NE(G) == 20

    H = IntGraph(5) ∨ IntGraph(4)
    @test G == H

    G = Cycle(9)
    H = Cycle(10)
    contract!(H, 1, 10)
    @test G == H

    G = Path(9)
    H = trim(G, 1)
    @test NV(H) == 0

    G = Complete(5)
    H = subdivide(G)
    @test NV(H) == NV(G) + NE(G)
    @test NE(H) == 2 * NE(G)

end

@testset "Constructors" begin
    G = Complete(5)
    @test NE(G) == 10
    G = Complete(4, 5)
    @test NE(G) == 20
    G = Complete([5, 5, 5])
    @test NE(G') == 30

    G = RandomTree(10)
    @test NE(G) == 9
    G = Grid(3, 3)
    @test NV(G) == 9
    G = Wheel(10)
    @test NV(G) == 10
    G = Cube(4)
    @test NV(G) == 16
    G = BuckyBall()
    @test NE(G) == 90
    G = Petersen()
    @test NE(G) == 15
    G = Paley(13)
    @test NE(G) == NE(G')
    G = RandomRegular(10, 3)
    @test NE(G) == 15
    G = Knight(5, 5)
    @test NV(G) == 25
    @test NE(HoffmanSingleton()) == 175
    p1 = char_poly(Hoffman())
    p2 = char_poly(Cube(4))
    @test p1 == p2
end

@testset "Platonics" begin
    G = Icosahedron()
    H = Dodecahedron()
    @test NE(G) == NE(H)
    G = Octahedron()
    H = Complete([2, 2, 2])
    @test NE(G) == NE(H)
    @test Tetrahedron() == Complete(4)
end

@testset "Unit distance" begin
    G = Spindle()
    @test is_unit_distance(G)
    G = Golomb()
    @test is_unit_distance(G)
end


@testset "Connectivity" begin
    G = Path(10)
    @test diam(G) == 9
    @test eccentricity(G, 2) == 8
    @test num_components(G) == 1
    @test spanning_forest(G) == G
    @test is_acyclic(G)
    @test is_cut_edge(G, 3, 4)
    @test radius(G) == 5
    @test graph_center(G) == Set([5, 6])

    G = Complete(5, 5)'
    @test num_components(G) == 2
    H = spanning_forest(G)
    @test num_components(H) == 2
    @test NE(H) == 8

    G = Cycle(5) + Cycle(8) + Cycle(10)
    A = max_component(G)
    @test length(A) == 10
end

@testset "Matrices" begin
    G = Petersen()
    M = incidence(G)
    L = laplace(G)
    @test L == M * M'
    A = adjacency(G)
    v = A * ones(10)
    @test v == 3 * ones(Int, 10)
end

@testset "Twins" begin
    G = Complete(5, 3)
    @test twins(G) == bipartition(G)
end

@testset "Coloring" begin
    G = RandomTree(10)
    d = two_color(G)
    @test Set(values(d)) == Set([1, 2])
    f = greedy_color(G)
    @test length(keys(f)) == NV(G)
end

@testset "Euler" begin
    G = Cube(4)
    tour = euler(G)
    @test length(tour) == NE(G) + 1
    @test tour[1] == tour[end]
end

@testset "Hamiltonian" begin
    G = Cube(4)
    tour = hamiltonian_cycle(G)
    @test length(tour) == NV(G)
end

@testset "Girth" begin
    G = Cube(4)
    @test girth(G) == 4
    G = RandomTree(10)
    @test girth(G) == 0
end

@testset "Bisect" begin
    G = RandomTree(10)
    A, B = bisect(G)
    @test G.V == union(A, B)
    @test length(intersect(A, B)) == 0
    @test length(cross_edges(G, A, B)) == 1
end

@testset "Transitive" begin
    G = RandomTree(10)
    D = transitive_orientation(G)
    @test G == simplify(D)
    @test num_trans_orientations(G) == 2
end

@testset "Prufer" begin
    for k = 1:10
        G = RandomTree(10)
        code = prufer_code(G)
        H = prufer_restore(code)
        @test G == H
    end
end

@testset "Polynomials" begin
    G = Complete(3, 4)
    p = indep_poly(G)
    @test coeffs(p) == [1; 7; 9; 5; 1]

    p = matching_poly(G)
    @test coeffs(p) == [0, -24, 0, 36, 0, -12, 0, 1]

    p = interlace(G)
    @test coeffs(p) == [0, 2, 3, 4, 3, 1]

end


# DIRECTED GRAPH STUFF

@testset "Basic Directed" begin
    G = StringDigraph()
    add!(G, "alpha", "bravo")
    add!(G, "bravo", "charlie")
    @test NV(G) == 3
    @test NE(G) == 2
    @test sum(out_deg(G)) == sum(in_deg(G))

    H = simplify(relabel(G))
    @test H == Path(3)
end

@testset "Digraph Constructors" begin
    G = DirectedPath(10)
    add!(G, 10, 1)
    @test G == DirectedCycle(10)

    G = DirectedComplete(10, false)
    @test NE(G) == 10 * 9
    G = DirectedComplete(10, true)
    @test NE(G) == 10 * 10

    G = RandomTournament(10)
    @test NE(G) == 45
end

@testset "Directed Distance" begin
    G = DirectedCycle(10)
    @test diam(G) == 9
end

@testset "Directed Euler" begin
    G = TorusDigraph(4, 4)
    P = euler(G)
    @test length(P) == NE(G) + 1
end

@testset "Directed Hamiltonian Cycle" begin
    G = TorusDigraph(4, 4)
    P = hamiltonian_cycle(G)
    @test length(P) == NV(G)
end

@testset "Strong Connectivity" begin
    G = TorusDigraph(5, 5)
    @test is_strongly_connected(G)
end


@testset "Directed Matrices" begin
    G = RandomTournament(10)
    A = adjacency(G)
    B = A + A'
    @test B == adjacency(Complete(10))

    G = RandomTournament(10)
    M = incidence(G)
    @test M * M' == laplace(Complete(10))
end

@testset "Hypergraphs" begin
    H = IntHypergraph(2)

    add!(H, [1, 2, 3])
    add!(H, [3, 4])

    @test eltype(H) == Int

    @test sort(vlist(H)) == [1, 2, 3, 4]
    @test length(elist(H)) == 2

    @test NV(H) == 4
    @test NE(H) == 2
    @test has(H, 3)
    @test has(H, [2, 3, 1])

    G = SimpleGraph(H)
    @test is_connected(G)

    @test deg(H, 3) == 2

    add!(H, [4, 5])
    @test delete!(H, 4)
    @test NV(H) == 4
    @test NE(H) == 1

    add!(H, 4, 5, 6)
    @test is_uniform(H)

    G = Cycle(8)
    H = SimpleHypergraph(G)
    @test is_uniform(H)
    @test G.V == H.V
    @test NE(H) == NE(G)

    A = rand(6, 10) .> 0.5
    H = SimpleHypergraph(A)
    B = Float64.(A)
    K = SimpleHypergraph(B)
    @test H == K

    H = CompleteHypergraph(6, 3)
    @test NE(H) == 20

end


@testset "Rotation Systems" begin
    G = Grid(3, 3)
    @test euler_char(G) == 2
    G = Cycle(5)
    set_rot(G)
    @test euler_char(G) == 2
    G = Dodecahedron()
    @test euler_char(G) == 2
    H = dual(G)
    @test char_poly(Icosahedron()) == char_poly(H)
    @test euler_char(H) == 2
end
