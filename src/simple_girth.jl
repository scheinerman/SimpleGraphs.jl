export girth, girth_cycle

"""
`girth_cycle(G)` returns a shorest cycle of `G` as an array listing
the vertices on that cycle, or an empty array if `G` is acyclic.

*Warning*: This implementation is quite inefficient.
"""
function girth_cycle{T}(G::SimpleGraph{T})
  best_path = T[]
  if is_acyclic(G)
    return best_path
  end
  best = NV(G)+1

  for e in elist(G)
    u,v = e
    delete!(G,u,v)
    P = find_path(G,u,v)
    add!(G,u,v)
    nP = length(P)
    if  0 < nP < best
      best = nP
      best_path = P
    end
  end
  return best_path
end



"""
`girth(G)` computes the length of a shortest cycle in `G` or returns `0`
if `G` is acyclic.

*Warning*: This implementation is quite inefficient.
"""
girth(G::SimpleGraph) = length(girth_cycle(G))
