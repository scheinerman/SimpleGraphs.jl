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

@testset "Connectivity" begin
    G = Path(10)
    @test diam(G)==9
    @test num_components(G) == 1
    @test spanning_forest(G) == G
    @test is_acyclic(G)
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

end


@testset "More" begin
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
end
