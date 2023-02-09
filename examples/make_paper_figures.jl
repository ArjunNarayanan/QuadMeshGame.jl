using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh

function plot_mesh(mesh; vertex_size = 70, fontsize = 60)
    fig = PQ.plot_mesh(
        QM.active_vertex_coordinates(mesh), 
        QM.active_quad_connectivity(mesh), 
        number_vertices=true, 
        number_elements=true, 
        # internal_order=true, 
        fontsize = fontsize,
        vertex_size = vertex_size)[1]
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
fig.savefig("examples/paper_figures/flip-0.png")
QM.left_flip!(mesh, 1, 2)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/left-flip-0.png")
QM.right_flip!(mesh, 1, 2)
QM.right_flip!(mesh, 1, 2)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/right-flip-0.png")
##

##
vertices = [0. 0. 1. 1. 2. 2.
            0. 1.5 0. 1.5 0. 1.5]
connectivity = [1 3 4 2
                3 5 6 4]
mesh = QM.QuadMesh(vertices, connectivity')
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/split-0.png")
QM.split!(mesh, 1, 2)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/split-1.png")
mesh = QM.QuadMesh(vertices, connectivity')
QM.split!(mesh, 2, 4)
fig = plot_mesh(mesh)
fig.savefig("examples/paper_figures/split-2.png")
##


##
mesh = QM.square_mesh(2)
fig = plot_mesh(mesh, fontsize = 50)
fig.savefig("examples/paper_figures/global-split-0.png")
tracker = QM.Tracker()
QM.global_split_without_loops!(mesh, 2, 1, tracker, 10)
QM.averagesmoothing!(mesh)
fig = plot_mesh(mesh, fontsize = 50)
fig.savefig("examples/paper_figures/global-split-1.png")
##

