# Everying Euler trails/tours

export euler

# This function finds an Euler trail/tour given initial
# vertices. Returns the trail if it exists of [] if it does not.

"""
`euler(G,u,v)` finds an Euler trail in `G` starting at `u` and ending
at `v` returned as a list of vertices (in the order they are visited
on the trail).

`euler(G,u)` finds an Euler tour beginning and ending at
`u`. Alternatively, call `euler(G)` and the initial/final vertex will
be selected for you.

Note: The algorithm will succeed even if there are isolated vertices
in the graph (just don't choose an isolated vertex as the first/last).

If no Euler trail/tour exists, an empty list is returned.
"""
function euler(G::SimpleGraph{T}, u::T, v::T) where {T}
    notrail = T[]

    # perform basic checks:
    if ! (has(G,u) && has(G,v))
        error("One or both of these vertices is not in this graph")
    end

    # special case: if all vertices have degree zero
    if all( [deg(G,x)==0 for x in G.V] )
        if u==v
            return [u]
        else
            return notrail
        end
    end

    # if either vertex has degree zero, we're doomed
    if deg(G,u)==0 || deg(G,v)==0
        return notrail
    end

    # vertex degree checks
    if u==v
        for x in G.V
            if deg(G,x)%2 == 1
                return notrail
            end
        end
    else        # u != v
        for x in G.V
            if x==u || x==v
                if deg(G,x)%2==0
                    return notrail
                end
            else
                if deg(G,x)%2==1
                    return notrail
                end
            end
        end
    end

    # Remove isolates and check for connectivity
    GG = trim(G)
    if !is_connected(GG)
        return notrail
    end

    # all tests have been satisfied. Now find the trail in GG using a
    # helper function.
    return euler_work!(GG,u)
end

# special case: find an Euler tour from a specified vertex
function euler(G::SimpleGraph{T},u::T) where {T}
    return euler(G,u,u)
end

# special case: find any Euler tour. If the graph is connected, any
# vertex will do but if there are isolated vertices, we don't want to
# pick one of those!
function euler(G::SimpleGraph{T}) where {T}
    if cache_check(G,:euler)
      return cache_recall(G,:euler)
    end
    if NV(G)==0
        return T[]
    end

    verts = vlist(G)

    # search for a vertex that isn't isolated
    for u in verts
        if deg(G,u) > 0
            return euler(G,u,u)
        end
    end

    # if we reach here, the graph only has isolated vertics. Let it
    # work from any isolated vertex (and likely fail).
    u = verts[1]
    tour = euler(G,u,u)
    cache_save(G,:euler,tour)
    return tour
end

# private helper function for euler()
function euler_work!(G::SimpleGraph{T}, u::T) where {T}
    trail = T[]

    while true
        # if last vertex
        if NV(G)==1
            append!(trail,[u])
            return trail
        end

        # get the neighbors of u
        Nu = G[u]

        # if only one neighbor delete and move on
        if length(Nu)==1
            w = Nu[1]
            SimpleGraphs.delete!(G,u)
            append!(trail,[u])
            u = w
        else
            for w in Nu
                if ! is_cut_edge(G,u,w)
                    SimpleGraphs.delete!(G,u,w)
                    append!(trail,[u])
                    u = w
                    break
                end
            end
        end
    end
    error("This can't happen")
end
