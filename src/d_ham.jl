export directed_ham_cycle

#check if it is safe to add vertex v to the path
function isSafe(v::T, G::SimpleDigraph{T}, path::Stack{T}) where {T}
    prev = top(path)

    #check if the added vertex is an out_neighbor of the previous vertex
    Nv = out_neighbors(G, prev)
    if length(Nu) == 0
        return false
    end
    if (!in(v, Nv))
        return false
    end

    #check if the vertex already exists in the path
    if (in(v,path))
        return false
    end

    return true
end

function hamCycle(G::SimpleDigraph{T}, path::Stack{T}) where {T}
    #if all vertices are included in the cycle
    if length(path) == NV(G)
        #check if last vertex is connected to first vertex in path
        Nv = out_neighbors(G, top(path))
        if in(path[1], Nv)
            return true
        else
            return false
        end
    end

    #try different vertices as the next candidate in the Hamiltonian cycle
    vlist = collect(G.V)
    for v in vlist
        if (isSafe(v, G, path))
            push!(path, v)
            #cycle
            if (hamCycle(G,path) == true)
                return true
            end
            pop!(path)
        end
    end
    return false
end

#check if a directed graph contains a hamiltonian cycle
function directed_ham_cycle(G::SimpleDigraph{T}) where {T}
    result = Stack{T}()
    vlist = collect(G.V)

    #check if there are any isolated vertices
    simpleG = simplify(G)
    if (!is_connected(simpleG))
        return result
    end


    for v in vlist
        push!(result,v)
        if (hamCycle(G,result))
            return result
        end
        result = Stack{T}()
    end

    return result
end
