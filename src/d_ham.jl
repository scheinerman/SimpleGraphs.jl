export directed_ham_cycle

#check if it is safe to add vertex v to the path
function isSafe(v::T, G::SimpleDigraph{T}, path::Array{T}) where {T}
    prev = path[length(path)]

    #check if the added vertex is an out_neighbor of the previous vertex
    Nv = out_neighbors(G, prev)
    if (!in(v,Nv))
        return false
    end

    #check if the vertex already exists in the path
    if (in(v,path))
        return false
    end

    return true
end

function hamCycle(G::SimpleDigraph{T}, path::Array{T}) where {T}
    #if all vertices are included in the cycle
    if length(path) == NV(G)
        #check if last vertex is connected to first vertex in path
        Nv = out_neighbors(G, path[length(path)])
        if in(path[0], Nv)
            return true
        else
            return false
        end
    end

    #try different vertices as the next candidate in the Hamiltonian cycle
    vlist = collect(G.V)
    for v in vlist
        if (isSafe(v, G, path))
            append!(path, v)
            #cycle
            if (hamCycle(G,path) == true)
                return true
            end
            deleteat!(path,length(path))
        end
    end
    return false
end

#check if a directed graph contains a hamiltonian cycle
function directed_ham_cycle(G::SimpleDigraph{T}) where {T}
    result = T[]
    vlist = collect(G.V)

    #check if there are any isolated vertices
    simpleG = simplify(G)
    if (!is_connected(simpleG))
        return result
    end

    marked = zeros(Int, length(vlist))

    for v in vlist
        append!(result,v)
        if (hamCycle(G,result))
            return result
        end
        result = T[]
    end

    return result
end
