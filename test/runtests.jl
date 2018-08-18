using Test
using SimpleGraphs

# This is woefully inadequate. Just a placeholder for now.

G = Petersen()
@test NV(G)==10
