using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh

vertices = [0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0]
connectivity = [1 2 4 5
    4 5 7 8
    5 6 8 9
    2 3 5 6]
mesh = QM.QuadMesh(vertices, connectivity)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
node_numbers=true, elem_numbers=true, internal_order=true)
fig.tight_layout()
# fig.savefig("examples/figures/2x2mesh.png")