# These functions are used to hold "expensive" values in case they are
# needed again. Note that if the graph is modified, the cache should be
# wiped clean.

# Here is a list of symbols and their associated meanings.

# :num_comps (Int) is the number of connected components.
# :components (Partition) is a partion of V into connected components.

"""
`cache_clear(G)` clears all items in `G`'s cache.
"""
function cache_clear(G::SimpleGraph)
  if length(G.cache) > 0
    G.cache=Dict{Symbol,Any}()
  end
  nothing
end

"""
`cache_check(G,item)` checks if the symbol `item` is a valid key.
"""
cache_check(G::SimpleGraph, item::Symbol)::Bool = haskey(G.cache,item)

"""
`cache_recall(G,item)` retreives the value associated with `item`.

**WARNING**: No check is done to see if this value is defined. Be
sure to use `cache_check` first!
"""
cache_recall(G::SimpleGraph,item::Symbol) = deepcopy(G.cache[item])

"""
`cache_save(G,item,value)` saves `value` associated with
the symbol (key) `item` in the cache for this graph.
"""
cache_save(G::SimpleGraph,item::Symbol,value) = G.cache[item]=deepcopy(value)
