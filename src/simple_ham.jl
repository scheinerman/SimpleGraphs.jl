export hamiltonian_cycle

"""
`hamiltonian_cycle(G::SimpleGraph)` returns a Hamiltonian cycle in the
graph (if one exists) or an empty array (otherwise). This works
reasonably well for small graphs.
"""
function hamiltonian_cycle(G::SimpleGraph)
    if cache_check(G,:hamiltonian_cycle)
      return cache_recall(G,:hamiltonian_cycle)
    end
    T = vertex_type(G)

    # rule out some simple non-Hamiltonian graphs
    if NV(G) < 3 || minimum(deg(G)) < 2 || !is_connected(G)
        return T[]
    end

    n = NV(G)
    path = Array{T,1}(undef,n)  # we'll put the answer here


    used = Dict{T,Bool}()
    for v in G.V
        used[v] = false
    end

    VV = vlist(G)
    v = VV[1]
    used[v] = true
    path[1] = v

    if ham_extend(G,VV,1,used,path)
        cache_save(G,:hamiltonian_cycle,path)
        return path
    else
        path = T[]
        cache_save(G,:hamiltonian_cycle,path)
        return path
    end
end


function ham_extend(G::SimpleGraph,
                    VV::Array,
                    idx::Int,
                    used::Dict,
                    path::Array)
    # println(path[1:idx])  # debug
    n = NV(G)
    v = path[idx]

    if idx == n
        return has(G,path[1],path[n])
    end

    for w in G[v]
        if !used[w]
            path[idx+1] = w
            used[w] = true
            if ham_extend(G,VV,idx+1,used,path)
                return true
            end
            used[w]=false
        end
    end
    return false
end

function ham_check(G,path::Array)
    n = NV(G)
    if length(path) != n
        return false
    end

    for k=1:n-1
        if !has(G,path[k],path[k+1])
            return false
        end
    end
    return has(G,path[1],path[n])
end
