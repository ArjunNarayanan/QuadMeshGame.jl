using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh


##
vertices = [0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0]
connectivity = [1 2 4 5
    4 5 7 8
    5 6 8 9
    2 3 5 6]
mesh = QM.QuadMesh(vertices, connectivity)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/2x2mesh.png")
##


##
mesh = QM.square_mesh(4)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true)
fig.tight_layout()
fig.savefig("examples/figures/4x4mesh.png")
##


##
mesh = QM.square_mesh(2)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/left-flip-initial.png")

QM.left_flip!(mesh, 2, 1)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/left-flip-final.png")
##


##
mesh = QM.square_mesh(2)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/split-initial.png")

QM.split!(mesh, 4, 1)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/split-final.png")

QM.averagesmoothing!(mesh)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/split-final-smoothed.png")
##


##
mesh = QM.square_mesh(2)
QM.collapse!(mesh, 4, 1)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/collapse-final.png")
##

##
mesh = QM.square_mesh(2)
QM.collapse!(mesh, 3, 2)
QM.reindex_quads!(mesh)
QM.reindex_vertices!(mesh)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = 20)
fig.tight_layout()
fig.savefig("examples/figures/reindexed.png")
##

##
mesh = QM.square_mesh(2)
desired_degree = deepcopy(QM.active_vertex_degrees(mesh))
QM.left_flip!(mesh, 1, 3)
current_degree = deepcopy(QM.active_vertex_degrees(mesh))
vertex_score = desired_degree - current_degree
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), vertex_score = vertex_score)
fig.savefig("examples/figures/vertex_score.png")
##