export SimpleHypergraph, IntHypergraph

struct SimpleHypergraph{T}
    V::Set{T}                   # vertex set
    E::Set{Set{T}}              # edge set
    VE::Dict{T, Set{Set{T}}}    # VE[v] is the set of edges containing v
    function SimpleHypergraph{T}() where T
        if T==Any 
            error("Do not create hypergraphs with vertex type Any")
        end 
        VV = Set{T}()
        EE = Set{Set{T}}()
        VVEE = Dict{T, Set{Set{T}}}()
        new(VV,EE,VVEE)
    end
end


"""
`IntHypergraph()` creates a new hypergraph with vertex type `Int`.

`IntHypergraph(n)` creates a new hypergraph with vertex set
`{1,2,...,n}` and no edges.
"""
IntHypergraph() = SimpleHypergraph{Int}()

function IntHypergraph(n::Int)
    H = IntHypergraph()
    for v = 1:n
        add!(H,v)
    end
    return H
end

"""
`StringHypergraph()` creates a new hypergraph with vertex
type `String`.
"""
StringHypergraph = SimpleHypergraph{String}()


(==)(H::SimpleHypergraph, K::SimpleHypergraph) = H.V==K.V && H.E==K.E

"""
`simplify(H::SimpleHypergraph)` converts a hypergraph into a simple graph, `G`.
The vertices of `G` are the same as those in `H`. Two vertices of `G` are adjacent
iff they lie in a common edge of `H`.
"""
function simplify(H::SimpleHypergraph{T}) where T 
    G = SimpleGraph{T}()

    # copy the vertices into G 
    for v in H.V 
        add!(G,v)
    end

    # for each edge, make a clique 
    for e in H.E 
        ee = collect(e)
        k = length(ee)
        for i=1:k-1
            v = ee[i]
            for j=i+1:k 
                w = ee[j]
                add!(G,v,w)
            end 
        end
    end

    return G 
end

include("add-delete.jl")
include("query.jl")
include("graph.jl")
include("incidence.jl")
include("complete.jl")
include("random-hyper.jl")