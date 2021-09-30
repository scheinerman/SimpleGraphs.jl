# Extras for the `SimpleGraphs` Module

This directory will be for code that is potentially useful in graph theory work, 
but not included in the `SimpleGraphs` module.

## Iterating over trees

### All trees

The file `tree_iterator.jl` contains code to iterate over trees of a given size.

For example, the following code finds the degree sequence of all trees with 4 vertices:
```
julia> for T ∈ Trees(4)
       println(deg(T))
       end
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
```
Note that there are `n^(n-2)` trees with vertex set `{1,2,...,n}` and 
the code `for T ∈ Trees(n)` will iterate over all of them. So this is
useful (perhaps) up to `n=10`.

### Distinct trees

To iterate over distinct trees, we provide the function `distinct_trees(n)`. This is
not an iterator; it returns a list of all pairwise non-isomorphic trees with `n` 
vertices. This is practical only up to about `n=9`. For example:
```
julia> for T ∈ distinct_trees(5)
       println(deg(T))
       end
[4, 1, 1, 1, 1]
[3, 2, 1, 1, 1]
[2, 2, 2, 1, 1]
```
There are only three distinct trees (pairwise nonisomorphic) with 3 vertices.

The algorithm used by `distinct_trees` uses a heuristic, but gives correct results
up to `n=10` (and possible beyond, but I haven't checked).

### Precomputed distinct trees
Finding all distinct trees with 9 vertices takes several minutes. Finding all 
with 10 vertices takes hours. For convenience, we provide the function
`create_trees_table()` that generates a table from pre-computed Prufer codes. 

To generate the table of codes, use `create_code_table(nmax)`. This writes the codes
into a file named `codes.jl` that, in turn, is used by `create_trees_table()`.