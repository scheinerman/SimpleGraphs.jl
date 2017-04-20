# Module written by Ed Scheinerman, ers@jhu.edu
# distributed under terms of the MIT license

module SimpleGraphs
using DataStructures
using Iterators
using SimpleRandom
using Primes # needed for Paley graphs

"""
`AbstractSimpleGraph` is a parent class for `SimpleGraph` and `SimpleDigraph`.
"""
abstract AbstractSimpleGraph
export AbstractSimpleGraph

include("simple_core.jl")
include("cache.jl")
include("simple_ops.jl")
include("simple_constructors.jl")
include("platonic.jl")
include("simple_connect.jl")
include("simple_matrices.jl")
# include("disjoint_sets_helper.jl")
include("simple_converters.jl")
include("simple_coloring.jl")
include("simple_euler.jl")
include("simple_ham.jl")
include("simple_girth.jl")
include("bisect.jl")
include("trans_orient.jl")

include("d_simple_core.jl")
include("d_simple_constructors.jl")
include("d_simple_matrices.jl")
include("d_dist.jl")


end # module SimpleGraphs
