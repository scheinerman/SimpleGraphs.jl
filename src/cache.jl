# These functions are used to hold "expensive" values in case they are
# needed again. Note that if the graph is modified, the cache should be
# wiped clean.

export cache_clear, cache_on, cache_off, cache_recall, cache_check 

# We try to match the symbol's name with the function it saves.

"""
`cache_clear(G)` clears all items in `G`'s cache.

`cache_clear(G,item)` clears just that item.
"""
function cache_clear(G::SimpleGraph)
  if length(G.cache) > 0
    G.cache=Dict{Symbol,Any}()
  end
  nothing
end

cache_clear(G::SimpleGraph, item::Symbol) = delete!(G.cache,item)

"""
`cache_check(G,item)` checks if the symbol `item` is a valid key.
"""
cache_check(G::SimpleGraph, item::Symbol)::Bool = G.cache_flag && haskey(G.cache,item)

"""
`cache_recall(G,item)` retreives the value associated with `item`.

**WARNING**: No check is done to see if this value is defined. Be
sure to use `cache_check` first!
"""
cache_recall(G::SimpleGraph,item::Symbol) = deepcopy(G.cache[item])


"""
`cache_recall_fast(G,item)` is similar to `cache_recall` except we do not
make a copy of the object. Use this only for immutable saved values.
"""
cache_recall_fast(G::SimpleGraph,item::Symbol) = G.cache[item]


"""
`cache_save(G,item,value)` saves `value` associated with
the symbol (key) `item` in the cache for this graph.
"""
function cache_save(G::SimpleGraph, item::Symbol, value)
  cache_save_fast(G,item,deepcopy(value))
end

"""
`cache_save_fast(G,item,value)` is the same as `cache_save` but safe
for immutable values.
"""
function cache_save_fast(G::SimpleGraph, item::Symbol, value)
  if G.cache_flag
    G.cache[item]=value
  end
  nothing
end


"""
`cache_on(G)` activates results caching for this graph. See also: `cache_off`.
"""
cache_on(G::SimpleGraph) = G.cache_flag=true

"""
`cache_off(G)` deactivates cache checking. You may also wish to call
`cache_clear` to recover storage.

See also: `cache_on`.
"""
function cache_off(G::SimpleGraph)
  G.cache_flag=false
end
