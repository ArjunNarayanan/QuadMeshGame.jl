using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh


mesh = QM.square_mesh(4)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    node_numbers=true, elem_numbers=true, internal_order=true)
fig.tight_layout()
fig
fig.savefig("examples/figures/4x4mesh.png")


mesh = QM.square_mesh(2)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    node_numbers=true, elem_numbers=true, internal_order=true)
fig.tight_layout()
fig
fig.savefig("examples/figures/split-initial.png")

QM.split!(mesh, 4, 1)

QM.averagesmoothing!(mesh)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    node_numbers=true, elem_numbers=true, internal_order=true)
fig.tight_layout()

fig.savefig("examples/figures/split-final-smoothed.png")

mesh = QM.square_mesh(2)
QM.collapse!(mesh, 4, 1)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    node_numbers=true, elem_numbers=true, internal_order=true)
fig.tight_layout()
fig.savefig("examples/figures/collapse-final.png")

mesh = QM.square_mesh(2)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    node_numbers=true, elem_numbers=true, internal_order=true)
QM.collapse!(mesh, 3, 2)
QM.number_of_vertices(mesh)
QM.active_quad_connectivity(mesh)

QM.reindex_quads!(mesh)