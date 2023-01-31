using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh


function plot_mesh(mesh; vertex_size = 30, fontsize = 20)
    fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
    number_vertices=true, number_elements=true, internal_order=true, fontsize = fontsize,
    vertex_size = vertex_size)[1]
    fig.tight_layout()
    return fig
end

##
vertices = [0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0]
connectivity = [1 2 4 5
    4 5 7 8
    5 6 8 9
    2 3 5 6]
mesh = QM.QuadMesh(vertices, connectivity)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/2x2mesh.png")
##


##
mesh = QM.square_mesh(4)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/4x4mesh.png")
##


##
mesh = QM.square_mesh(2)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/left-flip-initial.png")

QM.left_flip!(mesh, 2, 1)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/left-flip-final.png")
##


##
mesh = QM.square_mesh(2)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/split-initial.png")

QM.split!(mesh, 4, 1)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/split-final.png")

QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/split-final-smoothed.png")
##


##
mesh = QM.square_mesh(2)
QM.collapse!(mesh, 4, 1)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/collapse-final.png")
##

##
mesh = QM.square_mesh(2)
QM.collapse!(mesh, 3, 2)
QM.reindex_quads!(mesh)
QM.reindex_vertices!(mesh)
fig = plot_mesh(mesh)
# fig.savefig("examples/figures/reindexed.png")
##


# boundary split
##
mesh = QM.square_mesh(2)
QM.boundary_split!(mesh, 4, 1)
fig = plot_mesh(mesh)
fig.savefig("examples/figures/boundary_split.png")
##


# global split
##
mesh = QM.square_mesh(5)
fig = plot_mesh(mesh, fontsize = 10, vertex_size=20)
fig.savefig("examples/figures/global-split-0.png")
tracker = QM.Tracker()
QM.global_split_without_loops!(mesh, 7, 2, tracker, 10)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh, fontsize = 10, vertex_size = 20)
fig.savefig("examples/figures/global-split-1.png")
QM.global_split_without_loops!(mesh, 15, 4, tracker, 10)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh, fontsize = 10, vertex_size = 20)
fig.savefig("examples/figures/global-split-2.png")
QM.global_split_without_loops!(mesh, 5, 1, tracker, 10)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh, fontsize = 10, vertex_size = 20)
fig.savefig("examples/figures/global-split-3.png")
##




##
mesh = QM.square_mesh(2)
desired_degree = deepcopy(QM.active_vertex_degrees(mesh))
QM.left_flip!(mesh, 1, 3)
current_degree = deepcopy(QM.active_vertex_degrees(mesh))
vertex_score = desired_degree - current_degree
fig = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), vertex_score = vertex_score)
# fig.savefig("examples/figures/vertex_score.png")
##


##
mesh = QM.square_mesh(3);
desired_degree = deepcopy(QM.active_vertex_degrees(mesh))
QM.split!(mesh, 3, 2)
QM.collapse!(mesh, 4, 1)
env = QM.GameEnv(mesh, desired_degree, 10)
QM.reindex_game_env!(env);
QM.averagesmoothing!(env.mesh)
fig = PQ.plot_mesh(QM.active_vertex_coordinates(env.mesh), QM.active_quad_connectivity(env.mesh), 
    vertex_score = QM.active_vertex_scores(env))
fig.savefig("examples/figures/game_env.png")
##