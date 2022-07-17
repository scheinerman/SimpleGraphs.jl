# These functions are used to hold "expensive" values in case they are
# needed again. Note that if the graph is modified, the cache should be
# wiped clean.

export cache_clear, cache_on, cache_off, cache_recall, cache_check, cache_save
# but we don't export cache_save


# We try to match the symbol's name with the function it saves.

"""
`cache_clear(G)` clears all items in `G`'s cache.

`cache_clear(G,item)` clears just that item.
"""
function cache_clear(G::UndirectedGraph)
    if length(G.cache) > 0
        G.cache = Dict{Symbol,Any}()
    end
    nothing
end

cache_clear(G::UndirectedGraph, item::Symbol) = delete!(G.cache, item)

"""
`cache_check(G,item)` checks if the symbol `item` is a valid key.
"""
cache_check(G::UndirectedGraph, item::Symbol)::Bool = G.cache_flag && haskey(G.cache, item)

"""
`cache_recall(G,item)` retreives the value associated with `item`.

**WARNING**: No check is done to see if this value is defined. Be
sure to use `cache_check` first!
"""
cache_recall(G::UndirectedGraph, item::Symbol) = G.cache[item]



"""
`cache_save(G,item,value)` saves `value` associated with
the symbol (key) `item` in the cache for this graph.
"""
function cache_save(G::UndirectedGraph, item::Symbol, value)
    if G.cache_flag
        G.cache[item] = value
    end
    nothing
end

"""
`cache_on(G)` activates results caching for this graph. See also: `cache_off`.
"""
cache_on(G::UndirectedGraph) = G.cache_flag = true

"""
`cache_off(G)` deactivates cache checking. You may also wish to call
`cache_clear` to recover storage.

See also: `cache_on`.
"""
function cache_off(G::UndirectedGraph)
    G.cache_flag = false
end
