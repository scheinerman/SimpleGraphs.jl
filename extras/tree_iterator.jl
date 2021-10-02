using SimpleGraphs, SimpleGraphAlgorithms, ProgressMeter


"""
    Trees(n)
This type is used for iterating over all trees with vertex set `{1,2,...,n}`, like this:

```
for T ∈ Trees(6)
    some_action(T)
end
```

**WARNING**: There are `n^(n-2)` trees on `n` vertices. With `n=10`, that's 
one hundred million.
"""
struct Trees
    n::Int
end

function Base.iterate(T::Trees, state = 0)
    N = T.n
    NN = Int128(N)^(N - 2)
    if state == NN
        return nothing
    end

    code = Int.(digits(state, base = N, pad = N - 2) .+ 1)
    G = prufer_restore(code)
    name(G, "Tree")
    return (G, state + 1)
end

Base.length(T::Trees) = Int128(T.n)^(T.n - 2)
