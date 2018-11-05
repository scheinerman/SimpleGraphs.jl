export euler, is_cut_edge

function euler(G::SimpleDigraph{T}, u::T, v::T) where {T}
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

euler(G::SimpleDigraph,u) = euler(G,u,u)
euler(G::SimpleDigraph) = euler(G,first(G.V))


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
            push!(trail, u)
            return trail
        end

        if length(Nu) == 1
            v = Nu[1]
            push!(trail,u)
            delete!(G,u,v)
            u = v
        else
            for w in Nu
                if !is_cut_edge(G,u,w)
                    delete!(G,u,w)
                    push!(trail,u)
                    u = w
                    break
                end
            end
        end
    end
    error("Not gonna happen")
end
