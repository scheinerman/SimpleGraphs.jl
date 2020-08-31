


#  SimpleGraphs

[![Build Status](https://travis-ci.org/scheinerman/SimpleGraphs.jl.svg?branch=master)](https://travis-ci.org/scheinerman/SimpleGraphs.jl)


[![codecov.io](http://codecov.io/github/scheinerman/SimpleGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/scheinerman/SimpleGraphs.jl?branch=master)

---

## New version release notes

As of version 0.5.0 the polynomials returned by functions such as
`char_poly` are of type `SimplePolynomial`.

As of version 0.5.2 the function `vertex_type` is deprecated. Use 
`eltype` instead. 

---




This module defines three data types for working with graphs:

+ The `SimpleGraph` type represents *undirected* graphs without loops
  or multiple edges.
+ The `SimpleDigraph` type represents *directed* graphs in which there
  may be at most one directed edge `(u,v)` from a vertex `u` to a
  vertex `v`. There may also be a directed edge in the opposite
  direction, `(v,u)`.
+ The `SimpleHypergraph` type representing *hypergraphs* in which
  edges may be any subset of the vertex set.


Additional functionality can be found in these modules:
+ `DrawSimpleGraphs` for visualization.
+ `SimpleGraph Algorithms` for functions relying on [integer] linear programming.
+ `SimpleGraphRepresentations` for creating and analyzing some special
classes of graphs.


## User's Guide

Please see the [Wiki](https://github.com/scheinerman/SimpleGraphs.jl/wiki) for
extensive information pertaining to the `SimpleGraph` type.

The `SimpleDigraph` type is not so well developed nor documented. See the
source files in the `src` directory. Likewise, the `SimpleHypergraph`
type is in early stages of development.

## Thanks

Thank you to JHU students Tara Abrishami and Laura Bao for contributions
to this project.


## Please Help

This is a work in process with a lot of more features that
can/should be added. If you're interested in contributing, please
contact me. I'm especially interested in JHU undergraduates getting
involved.



Ed Scheinerman (ers@jhu.edu)
