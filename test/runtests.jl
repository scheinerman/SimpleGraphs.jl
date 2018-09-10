using Test
using SimpleGraphs
using LinearAlgebra
using SparseArrays
using SimplePartitions



@testset "Core" begin
    G = Path(10)
    name(G,"Example")
    @test name(G)=="Example"
    @test NV(G)==10
    @test NE(G)==9
    @test G[2] == [1,3]
    @test deg(G,2) == 2
    @test sum(deg(G)) == 2NE(G)

    G = IntGraph(2)
    add!(G,1,2)
    add!(G,1,3)
    add!(G,2,3)
    @test NV(G) == NE(G)
    A = adjacency(G)
    H = SimpleGraph(A)
    @test G==H

    G = StringGraph()
    add!(G,"alpha","beta")
    @test G["alpha", "beta"]
end

@testset "Ops" begin
    G = IntGraph(3)
    ee = [ 1 2; 2 3; 1 3]
    add_edges!(G,ee)
    delete!(G,1,2)
    @test NE(G) == 2
    G = Cycle(5)
    delete!(G,5)
    @test G == Path(4)

    G = line_graph(Cycle(5))
    @test deg(G) == 2*ones(5)

    H = G'
    @test G == H'

    G = Cycle(4)
    H = cartesian(G,G)
    @test NV(H) == NV(G)^2

    H = disjoint_union(Cycle(4), Cycle(5))
    @test NV(H) == 9
    @test NE(H) == 9

    G = join(IntGraph(5),IntGraph(4))
    @test NE(G) == 20

    G = Cycle(9)
    H = Cycle(10)
    contract!(H,1,10)
    @test G==H

    G = Path(9)
    H = trim(G,1)
    @test NV(H) == 0

end

@testset "Constructors" begin
    G = Complete(5)
    @test NE(G) == 10
    G = Complete(4,5)
    @test NE(G) == 20
    G = Complete([5,5,5])
    @test NE(G') == 30

    G = RandomTree(10)
    @test NE(G) == 9
    G = Grid(3,3)
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
    G = RandomRegular(10,3)
    @test NE(G) == 15
    G = Knight(5,5)
    @test NV(G) == 25
    @test NE(HoffmanSingleton()) == 175
    p1 = char_poly(Hoffman())
    p2 = char_poly(Cube(4))
    @test p1==p2
end

@testset "Platonics" begin
    G = Icosahedron()
    H = Dodecahedron()
    @test NE(G) == NE(H)
    G = Octahedron()
    H = Complete([2,2,2])
    @test NE(G) == NE(H)
    @test Tetrahedron() == Complete(4)
end



@testset "Connectivity" begin
    G = Path(10)
    @test diam(G)==9
    @test eccentricity(G,2) == 8
    @test num_components(G) == 1
    @test spanning_forest(G) == G
    @test is_acyclic(G)
    @test is_cut_edge(G,3,4)
    @test radius(G) == 5
    @test center(G) == Set([5,6])

    G = Complete(5,5)'
    @test num_components(G) == 2
    H = spanning_forest(G)
    @test num_components(H) == 2
    @test NE(H)==8
end

@testset "Matrices" begin
    G = Petersen()
    M = incidence(G)
    L = laplace(G)
    @test L == M*M'
    A = adjacency(G)
    v = A * ones(10)
    @test v == 3*ones(Int,10)
end

@testset "Coloring" begin
    G = RandomTree(10)
    d = two_color(G)
    @test Set(values(d)) == Set([1,2])
    f = greedy_color(G)
    @test length(keys(f)) == NV(G)
end

@testset "Euler" begin
    G = Cube(4)
    tour = euler(G)
    @test length(tour) == NE(G)+1
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
    A,B = bisect(G)
    @test G.V == union(A,B)
    @test length(intersect(A,B)) == 0
    @test length(cross_edges(G,A,B)) == 1
end

@testset "Transitive" begin
    G = RandomTree(10)
    D = transitive_orientation(G)
    @test G == simplify(D)
    @test num_trans_orientations(G) == 2
end
