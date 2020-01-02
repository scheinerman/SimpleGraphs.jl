export girth, girth_cycle

"""
`girth_cycle(G)` returns a shorest cycle of `G` as an array listing
the vertices on that cycle, or an empty array if `G` is acyclic.

*Warning*: This implementation is quite inefficient.
"""
function girth_cycle(G::SimpleGraph{T}) where {T}
  if cache_check(G,:girth_cycle)
    return cache_recall(G,:girth_cycle)
  end
  best_path = T[]
  if is_acyclic(G)
    cache_save(G,:girth_cycle,best_path)
    return best_path
  end
  best = NV(G)+1

  GG = deepcopy(G)

  for e in elist(GG)
    u,v = e
    SimpleGraphs.delete!(GG,u,v)
    P = find_path(GG,u,v)
    add!(GG,u,v)
    nP = length(P)
    if  0 < nP < best
      best = nP
      best_path = P
    end
  end
  cache_save(G,:girth_cycle,best_path)
  return best_path
end


"""
`girth(G)` computes the length of a shortest cycle in `G` or returns `0`
if `G` is acyclic.

**Warning**: This implementation is quite inefficient.
"""
function girth(G::SimpleGraph)
  if cache_check(G,:girth)
    return cache_recall(G,:girth)
  end
  g = length(girth_cycle(G))
  cache_save(G,:girth,g)
  return g
end
