export directed_euler, is_cut_edge, directed_ham_cycle

function directed_euler(G::SimpleDigraph{T}, u::T, v::T) where {T}
    notrail = T[]
    #check in_degrees and out_degrees of start and end vertex first
    if u == v
        if in_deg(G,u) != out_deg(G,u)
            return notrail
        end
    else
        if out_deg(G,u) - in_deg(G,u) != 1 ||
            in_deg(G,v) - out_deg(G,v) != 1
            return notrail
        end
    end

    #check if the undirected graph has an euler path
    simpleG = simplify(G)
    if length(euler(simpleG,u,v)) == 0
        return notrail
    end
    #check if connected
    #check if in_deg == out_deg for all other vertices

    GG = deepcopy(G)
    return euler_work!(GG, u)

end



# determine if an edge in a directed graph is a cut edge
function is_cut_edge(G::SimpleDigraph{T}, u::T, v::T) where {T}
    if !has(G,u,v)
        error("No such edge in this graph")
    end

    delete!(G,u,v)
    P = find_path(G,v,u)
    if (length(P) == 0)
        add!(G,u,v)
        return true
    else
        add!(G,u,v)
        return false
    end
end

# helper function to determine if there is euler path
# function euler_work!(G::SimpleDigraph{T}, u::T) where {T}
function euler_work!(G::SimpleDigraph{T}, u::T) where {T}
    trail = T[]
    #possibilities of non-cut-edges to traverse
#    choice = T[]
    while true
        Nu = out_neighbors(G,u)
        if (length(Nu)) == 0
            append!(trail, u)
            return trail
        end

        if length(Nu) == 1
            v = Nu[1]
            append!(trail,u)
            delete!(G,u,v)
            delete!(G,u)
            u = v
        else
            for w in Nu
                if !is_cut_edge(G,u,w)
                    delete!(G,u,w)
                    append!(trail,u)
                    u = w
                    break
                end
            end
        end
    end
    error("Not gonna happen")
end

function isSafe(v::T, G::SimpleGraph{T}, path::T[])
    prev = path[length(path)]

    #check if the added vertex is an out_neighbor of the previous vertex
    Nv = out_neighbors(prev)
    if (!in(v,Nv))
        return false
    end

    #check if the vertex already exists in the path
    if (in(v,path))
        return false
    end

    return true
end

function hamCycle(G::SimpleGraph{T}, path::T[])
    #if all vertices are included in the cycle
    if length(path) == NV(G)
        #check if last vertex is connected to first vertex in path
        Nv = out_neighbors(path[length(path)])
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
function directed_ham_cycle(G::SimpleGraph{T}) where {T}
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
