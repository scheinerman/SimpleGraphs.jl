# Various functions regarding graph connectivity

export components, num_components, is_connected, spanning_forest
export find_path, dist, diam, is_cut_edge, is_acyclic, wiener_index
export eccentricity, radius

# Find the components of the graph as a Set of subsets of the vertices

"""
`components(G)` returns the vertex sets of the connected components of
`G` (as a set of sets.
"""
function components{T}(G::SimpleGraph{T})
  P = Partition(G.V)
  for e in G.E
    (u,v) = e
    merge_parts!(P,u,v)
  end
  return P
end



#  OLD VERSION
# function components{T}(G::SimpleGraph{T})
#     VL = vlist(G)
#
#     # create the partition of the vertex set inside a "DisjointSets"
#     # Julia structure
#     parts = DisjointSets{T}(VL)
#     for e in G.E
#         (u,v) = e
#         union!(parts,u,v)
#         if num_groups(parts)==1
#             break
#         end
#     end
#     return set_of_sets(parts)
# end

# count the number of connected components
"""
`num_components(G)` returns the number of connected components in `G`.
"""
num_components{T}(G::SimpleGraph{T}) = num_parts(components(G))

# OLD VERSION
#
# function num_components{T}(G::SimpleGraph{T})
#     if NV(G)<2
#         return NV(G)
#     end
#     parts = DisjointSets{T}(vlist(G))
#     for e in G.E
#         (u,v) = e
#         union!(parts,u,v)
#         if num_groups(parts)==1
#             return 1
#         end
#     end
#     return num_groups(parts)
# end

# determine if the graph is connected
"""
`is_connected(G)` determines if `G` is connected.
"""
function is_connected{T}(G::SimpleGraph{T})
    return num_components(G) <= 1
end

# create a spanning forest of G, i.e., a maximal acyclic spanning
# subgraph. If G is connected, this is a tree.

"""
`spanning_forest(G)` creates a maximal acyclic subgraph of `G`.
"""



function spanning_forest{T}(G::SimpleGraph{T})
    H = SimpleGraph{T}()
    if NV(G) == 0
        return H
    end

    for v in G.V
        add!(H,v)
    end

    P = Partition(G.V)

    for e in G.E
        (u,v) = e
        if in_same_part(P,u,v)
            continue
        end
        add!(H,u,v)
        merge_parts!(P,u,v)
        if num_parts(P)==1
            break
        end
    end
    return H
end


# OLD VERSION
#
# function spanning_forest{T}(G::SimpleGraph{T})
#     H = SimpleGraph{T}()
#     if NV(G) == 0
#         return H
#     end
#
#     for v in G.V
#         add!(H,v)
#     end
#
#     parts = DisjointSets{T}(vlist(G))
#
#     for e in G.E
#         (u,v) = e
#         if in_same_set(parts,u,v)
#             continue
#         end
#         add!(H,u,v)
#         union!(parts,u,v)
#         if num_groups(parts)==1
#             break
#         end
#     end
#     return H
# end

# find a shortest path between vertices

"""
`find_path(G,s,t)` finds a shortest path from `s` to `t`. If no
such path exists, an empty list is returned.
"""
function find_path(G::AbstractSimpleGraph,s,t)
    T = vertex_type(G)
    if ~has(G,s) || ~has(G,t)
        error("Source and/or target vertex is not in this graph")
    end
    if s==t
        result = Array(T,1)
        result[1] = s
        return result
    end

    # set up a queue for vertex exploration
    Q = Queue(T)
    enqueue!(Q,s)

    # set up trace-back dictionary
    tracer = Dict{T,T}()
    tracer[s] = s

    while length(Q) > 0
        v = dequeue!(Q)
        Nv = G.N[v]
        for w in Nv
            if haskey(tracer,w)
                continue
            end
            tracer[w] = v
            enqueue!(Q,w)

            if w==t  # success!
                path = Array(T,1)
                path[1] = t
                while path[1] != s
                    v = tracer[path[1]]
                    unshift!(path,v)
                end
                return path

            end
        end
    end
    return T[]   # return empty array if no path found
end

# functions for finding distances between vertices in a graph. the
# distance between two vertices is the number of edges in a shortest
# path between them. if there is no such path, the distance is
# undefined (or infinite) but since we want the return value to be an
# Int, we use -1 to signal this.

# find the distance between specified vertices

"""
`dist(G,u,v)` finds the length of a shortest path from `u` to `v` in
`G`. Returns `-1` if no such path exists.

`dist(G,u)` finds the distance from `u` to all other vertices in
`G`. Result is returned as a `Dict`.

`dist(G)` finds all pairs of distances in `G`. Result is a `Dict`
whose `[u,v]` entry is the distance from `u` to `v`.
"""
function dist(G::AbstractSimpleGraph,u,v)
    return length(find_path(G,u,v))-1
end

# find all distances from a given vertex
function dist(G::AbstractSimpleGraph, v)
    T = vertex_type(G)
    d = Dict{T,Int}()
    if !has(G,v)
        error("Given vertex is not in this graph")
    end

    d[v] = 0
    Q = Queue(T)
    enqueue!(Q,v)

    while length(Q)>0
        w = dequeue!(Q)  # get 1st vertex in the queue
        Nw = G.N[w]
        for x in Nw
            if !haskey(d,x)
                d[x] = d[w]+1
                enqueue!(Q,x)
            end
        end
    end

    # record -1 for any vertices we missed
    for x in G.V
        if !haskey(d,x)
            d[x] = -1
        end
    end

    return d
end

# find all distances between all vertices
function dist(G::AbstractSimpleGraph)
    T = vertex_type(G)
    dd = Dict{Tuple{T,T},Int}()
    vtcs = vlist(G)

    for v in vtcs
        d = dist(G,v)
        for w in vtcs
            dd[(v,w)] = d[w]
        end
    end

    return dd
end

"""
`eccentricity(G,v)` returns the eccentricty of vertex `v`
in the graph `G`. This is the maximum distance from `v`
to another vertex (or -1 if the graph is not connected).
"""
function eccentricity(G::SimpleGraph, v)
  if !has(G,v)
    error("$v is not a vertex of this graph")
  end
  d = collect(values(dist(G,v)))
  if minimum(d)<0
    return -1
  end
  return maximum(d)
end

"""
`radius(G)` returns the radius of the graph `G`. This is the
minimum `eccentricity` of a vertex of `G` (or -1 if the graph
is not connected).
"""
function radius(G::SimpleGraph)
  D = dist_matrix(G)
  if minimum(D)<0
    return -1
  end
  return minimum(maximum(D,1))
end



"""
`wiener_index(G)` is the sum of the distances between vertices in `G`.
Returns -1 if `G` is not connected.
"""
function wiener_index(G::SimpleGraph)::Int
  if is_connected(G)
    return div(sum(values(dist(G))),2)
  end
  return -1
end

# Calculate the diameter of a graph, but return -1 if not connected.

"""
`diam(G)` returns the diameter of `G` or `-1` if `G` is not connected.
"""
function diam(G::SimpleGraph)
    if is_connected(G)
        return maximum(values(dist(G)))
    end
    return -1
end

# Determine if a given edge in a graph is a cut edge. If there is no
# such edge in the graph, an error is raised.

"""
`is_cut_edge(G,u,v)` [or `is_cut_edge(G,e)`] determins if `(u,v)` [or
`e`] is a cut edge of `G`.
"""
function is_cut_edge(G::SimpleGraph, u, v)
    if !has(G,u,v)
        error("No such edge in this graph")
    end

    delete!(G,u,v)
    P = find_path(G,u,v)
    result = false
    if length(P)==0
        result = true
    end
    add!(G,u,v)
    return result
end

# When called as is_cut_edge(G,e), we assume e is a tuple or list
# whose first two entries are the end points of the edge
function is_cut_edge(G::SimpleGraph, e)
    return is_cut_edge(G,e[1],e[2])
end


"""
`is_acyclic(G)` returns `true` if `G` has no cycles and `false`
otherwise.
"""
function is_acyclic(G::SimpleGraph)
  n = NV(G)
  m = NE(G)
  c = num_components(G)
  return m == n-c
end
