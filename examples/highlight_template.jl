using QuadMeshGame
using PlotQuadMesh

QM = QuadMeshGame
PQ = PlotQuadMesh

mesh = QM.square_mesh(5)

fig, ax = PQ.plot_mesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    # number_vertices=true,
    number_elements=true
)
fig

element = 13
half_edge = 1
position = (element-1)*4 + half_edge

fig, ax = PQ.plot_mesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    # number_vertices=true,
    vertex_size=50
)
fig
fig.savefig("examples/figures/template-0-numbered.png")


pairs = QM.make_edge_pairs(mesh)
x = reshape(mesh.connectivity, 1, :)
cx = QM.cycle_edges(x)

vertices = cx[:,position]

pcx = QM.zero_pad_matrix_cols(cx, 1)[:, pairs][3:end, :]
cpcx = QM.cycle_edges(pcx)

vertices = cpcx[:,position]

pcpcx = QM.zero_pad_matrix_cols(cpcx, 1)[:, pairs][3:end, :]
cpcpcx = QM.cycle_edges(pcpcx)

vertices = cpcpcx[:,position]
