using SimpleGraphs

include("tree_iterator.jl")

function create_code_table(last::Int = 8)
    code = Dict{Int,Vector{Vector{Int}}}()

    outfile = open("codes.jl", "w")

    println(outfile, "code = Dict{Int,Vector{Vector{Int}}}()")
    for k = 2:last
        println("Generating unlabeled trees with $k vertices")
        code[k] = prufer_code.(distinct_trees(k))
    end

    for k = 2:last
        println(outfile, "code[$k] = $(code[k])")
    end
    close(outfile)
    return nothing
end

function create_trees_table()
    include("codes.jl")
    unlabeled_trees = Dict{Int,Vector{SimpleGraph{Int}}}()
    for n in keys(code)
        unlabeled_trees[n] = prufer_restore.(code[n])
    end
    return unlabeled_trees
end
