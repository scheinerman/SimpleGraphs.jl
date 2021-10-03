using SimpleGraphs, SimpleGraphAlgorithms

const DEFAULT_FILE_NAME = "tree_codes.jl"

# initialize the table of unlabeled trees

"""
    init_trees_table()
Create a new table of distinct trees on 1 and 2 vertices.
"""
function init_trees_table()
    TT = Dict{Int,Vector{SimpleGraph{Int}}}()

    TT[1] = [IntGraph(1)]
    T = IntGraph(2)
    add!(T, 1, 2)
    TT[2] = [T]

    return TT
end

"""
    check_in(G,S)
See if the set `S` contains a graph isomorphic to `G`. Return `true` if so.
"""
function check_in(G::SimpleGraph{Int}, S::Set{SimpleGraph{Int}})
    if isempty(S)
        return false
    end
    for H ∈ S
        if is_iso(G, H)
            return true
        end
    end
    return false
end

"""
    extend_trees_table!(TT)
Given a table of distinct trees up to size `n`, extend that table to include 
all distinct trees of size `n+1`.
"""
function extend_trees_table!(TT::Dict{Int,Vector{SimpleGraph{Int}}})::Nothing
    n = maximum(keys(TT))
    outset = Set{SimpleGraph{Int}}()  # set of trees with n+1 vertices
    for T ∈ TT[n]
        for w = 1:n
            X = deepcopy(T)
            add!(X, w, n + 1)
            if check_in(X, outset)
                continue
            end
            push!(outset, X)
        end
    end

    TT[n+1] = collect(outset)

    @info "Added $(length(TT[n+1])) new trees with $(n+1) vertices"
    nothing
end

function build_trees_table(nmax::Int)
    TT = init_trees_table()
    while maximum(keys(TT)) < nmax
        @info "Adding trees of size $(maximum(keys(TT))+1)"
        extend_trees_table!(TT)
    end
    return TT
end

"""
    create_codes_table(TT)
Given a table of distinct trees, convert that into a table of Prufer codes.
This is used by `save_trees_table` and not useful to be called directly. 
"""
function create_codes_table(TT::Dict{Int64,Vector{SimpleGraph{Int}}})
    codes = Dict{Int64,Vector{Vector{Int}}}()
    codes[2] = [Int[]]
    for n = 3:maximum(keys(TT))
        codes[n] = prufer_code.(TT[n])
    end
    return codes
end

"""
    save_tree_table(TT, filename)
Save a trees table into a file specified by `filename`.
If the file name is omitted, use `codes.jl`.
"""
function save_trees_table(
    TT::Dict{Int64,Vector{SimpleGraph{Int}}},
    filename::String = DEFAULT_FILE_NAME,
)
    outfile = open(filename, "w")
    codes = create_codes_table(TT)
    println(outfile, "codes = Dict{Int,Vector{Vector{Int}}}()")
    for n = 2:maximum(keys(TT))
        print(outfile, "codes[$n] = ")
        println(outfile, codes[n])
    end
    close(outfile)
    nothing
end

"""
    load_trees_table(filename)
Create a table of distinct trees by reading in a file that has been
precomputed (and presumably saved using `save_tree_table`). If `filename`
is omitted, use `codes.jl`.
"""
function load_trees_table(filename::String = DEFAULT_FILE_NAME)
    include(filename)
    TT = init_trees_table()
    nmax = maximum(keys(codes))

    for n = 3:nmax
        TT[n] = prufer_restore.(codes[n])
    end
    @info "Read in table of distinct trees up to $nmax vertices"
    return TT

end
