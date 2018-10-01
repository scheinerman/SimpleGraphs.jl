"""
export directed_euler, is_cut_edge

function directed_euler(G::SimpleDigraph{T}, u::T, v::T)
    notrail = T[]
    #check in_degrees and out_degrees of start and end vertex first
    if u == v
        if in_deg(G,u) != out_deg(G,u)
            return notrail
        end
    else
        if out_deg(G,u) - out_deg(G,v) != 1 ||
            in_deg(G,v) - out_deg(G,u) != 1
            return notrail
        end
    end

    #check if the undirected graph has an euler path
    simpleG = simplify(G)
    if length(euler(simpleG,u,v)) == 0
        return notrail
    end

    GG = deepcopy(G)
    return euler_work!(GG, u)

end



# determine if an edge in a directed graph is a cut edge
function is_cut_edge(G::SimpleDigrpah{T}, u::T, v::T)
    if !has(G,u,v)
        error("No such edge in this graph")
    end

    delete!(G,u,v)
    P = find_path(G,u,v)
    if (length(P) == 0)
        add!(G,u,v)
        return true
    else
        add!(G,u,v)
        return false
    end
end

# helper function to determine if there is euler path
function euler_work!(G::SimpleDigraph{T}, u::T) where {T}
    trail = T[]
    while true
        if NV(G) == 1
            append!(trail, u)
        end

        NV = out_neighbors(G,u)
        if length(NV) == 1
            v = NV[1]
            delete!(G,v)
            append!(trail,v)
            u = v
        else
            for w in NV
                if !is_cut_edge(G,u,w)
                    delete!(G,u,w)
                    append!(trail, u)
                    u = w
                    break
                end
            end
        end
    end
    error("This can't happen")
end
"""
