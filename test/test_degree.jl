using Random
using Revise
using QuadMeshGame
using RandomQuadMesh
using PlotQuadMesh
using PyPlot


QM = QuadMeshGame
RM = RandomQuadMesh
PQ = PlotQuadMesh

Random.seed!(123)


# angles = range(0.0, stop= 360, length = 1000)
# fig, ax = subplots()
# ax.plot(angles, degrees)
# fig

p = RM.random_polygon(10)
angles = QM.polygon_interior_angles(p)
degrees = QM.desired_degree.(angles)
mesh = RM.quad_mesh(p)
boundary_indices = [QM.find_point_index(mesh.p, point) for point in eachcol(p)]
d0 = fill(4, size(mesh.p,2))
d0[boundary_indices] .= degrees

# p = [p p[:,1]]
# fig, ax = subplots()
# ax.plot(p[1,:], p[2,:])
# ax.scatter(p[1,:], p[2,:])
# ax.axis("equal")
# fig