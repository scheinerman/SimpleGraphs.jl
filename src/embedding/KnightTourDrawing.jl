using SimpleGraphs
using PyPlot


"""
`KnightTourDrawing(r,c)` illustrates a Knight's tour of an r-by-c
chessboard returning `true` if the tour exists and `false` if not.
"""
function KnightTourDrawing(r::Int=6, c::Int=6)::Bool
    G = Knight(r,c)
    println("Searching for a Hamiltonian cycle in an $r-by-$c Knight's move graph")
    tic()
    h = hamiltonian_cycle(G)
    println("Finished")
    toc()

    if length(h)==0
        println("Sorry. This graph is not Hamiltonian")
        return false
    end

    T = vertex_type(G)
    H = SimpleGraph{T}()
    for v in G.V
        add!(H,v)
    end

    for k=1:NV(H)-1
        add!(H,h[k],h[k+1])
    end

    add!(H,h[1],h[end])

    clf()

    xy = getxy(H)

    for v in H.V
        xy[v] = collect(v)
    end

    embed(H,xy)

    draw(H)

    for a=0:c
        plot( [0.5, r+0.5], [a+0.5, a+0.5], color="black", linestyle=":")
    end

    for b=0:r
        plot( [b+0.5, b+0.5], [0.5, c+0.5], color="black", linestyle=":")
    end

    axis([-1,r+1,-1,c+1])

    return true

end
