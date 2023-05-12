using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh

function plot_mesh(mesh; vertex_size = 70, fontsize = 60)
    fig, ax = PQ.plot_mesh(
        QM.active_vertex_coordinates(mesh), 
        QM.active_quad_connectivity(mesh), 
        number_vertices=true, 
        number_elements=true, 
        # internal_order=true, 
        fontsize = fontsize,
        vertex_size = vertex_size)
    fig.tight_layout()
    return fig
end

##
vertices = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
connectivity = [1 3 4 2
                3 5 6 4]
mesh = QM.QuadMesh(vertices, connectivity')
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/flips/flip-0.png")
QM.left_flip!(mesh, 1, 2)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/flips/left-flip-0.png")
QM.right_flip!(mesh, 1, 2)
QM.right_flip!(mesh, 1, 2)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/flips/right-flip-0.png")
##

##
vertices = [
    0. 0. 0. 2. 2. 2. 4. 4. 4.
    0. 1. 2. 0. 1. 2. 0. 1. 2.
]
connectivity = [
    1 4 5 2
    2 5 6 3
    4 7 8 5
    5 8 9 6
]
mesh = QM.QuadMesh(vertices, connectivity')
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/split-collapse/split-0.png")
QM.split!(mesh, 1, 3)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/split-collapse/split-1.png")
# mesh = QM.QuadMesh(vertices, connectivity')
# QM.split!(mesh, 2, 4)
# fig = plot_mesh(mesh)
# fig.savefig("examples/paper_figures/split-2.png")
##


##
mesh = QM.square_mesh(2)
fig = plot_mesh(mesh, fontsize = 50)
fig.savefig("examples/paper_figures/global-split/global-split-0.png")
tracker = QM.Tracker()
QM.global_split_without_loops!(mesh, 2, 1, tracker, 10)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh, fontsize = 50)
fig.savefig("examples/paper_figures/global-split/global-split-1.png")
##

##
mesh = QM.square_mesh(2)
is_geometric_vertex = falses(9)
is_geometric_vertex[[1,3,7,9]] .= true
mesh = QM.QuadMesh(QM.active_vertex_coordinates(mesh),
                   QM.active_quad_connectivity(mesh),
                   is_geometric_vertex=is_geometric_vertex)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/global-cleanup/cleanup-0.png")
tracker = QM.Tracker()
QM.cleanup_path!(mesh, 1, 2, 10, tracker)
QM.reindex!(mesh)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/global-cleanup/cleanup-1.png")
##