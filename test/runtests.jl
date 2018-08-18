using Test
using SimpleGraphs

Pkg.clone("https://github.com/scheinerman/SimpleRandom.jl.git")
Pkg.clone("https://github.com/scheinerman/SimplePartitions.jl.git")
# This is woefully inadequate. Just a placeholder for now.

G = Petersen()
@test NV(G)==10
