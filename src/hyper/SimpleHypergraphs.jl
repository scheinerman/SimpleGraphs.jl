export SimpleHypergraph, IntHypergraph

struct SimpleHypergraph{T}
    V::Set{T}                   # vertex set
    E::Set{Set{T}}              # edge set
    VE::Dict{T, Set{Set{T}}}    # VE[v] is the set of edges containing v
    function SimpleHypergraph{T}() where T
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

include("add-delete.jl")
include("query.jl")
include("graph.jl")
include("incidence.jl")
