# Module written by Ed Scheinerman, ers@jhu.edu
# distributed under terms of the MIT license

module SimpleGraphs
using DataStructures
using SimpleRandom
using Primes # needed for Paley graphs
using LinearAlgebra
using Statistics
using IterTools
using Random
using AbstractLattices
using SimplePolynomials
using LinearAlgebraX
using RingLists



import AbstractLattices: dist, ∨

"""
`AbstractSimpleGraph` is a parent class for `SimpleGraph` and `SimpleDigraph`.
"""
abstract type AbstractSimpleGraph end
export AbstractSimpleGraph

include("simple_core.jl")
include("d_simple_core.jl")

include("cache.jl")
include("simple_ops.jl")
include("simple_constructors.jl")
include("platonic.jl")
include("simple_connect.jl")
include("simple_matrices.jl")
# include("disjoint_sets_helper.jl")
# include("simple_converters.jl")
include("simple_coloring.jl")
include("simple_euler.jl")
include("simple_ham.jl")
include("simple_girth.jl")
include("bisect.jl")
include("trans_orient.jl")
include("interlace.jl")
include("matching_poly.jl")
include("indep_poly.jl")
include("twins.jl")
include("rotation_system.jl")

include("d_simple_constructors.jl")
include("d_simple_matrices.jl")
include("d_dist.jl")
include("d_euler.jl")
include("d_ham.jl")
include("embedding/embedding.jl")

include("hyper/SimpleHypergraphs.jl")

end # module SimpleGraphs
