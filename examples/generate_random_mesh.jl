using RandomQuadMesh
using QuadMeshGame
using PlotQuadMesh

RQ = RandomQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh

function initialize_random_mesh(poly_degree, quad_alg="catmull-clark", round_desired_degree=true)
    boundary_pts = RQ.random_polygon(poly_degree)
    angles = QM.polygon_interior_angles(boundary_pts)

    bdry_d0 = round_desired_degree ? QM.rounded_desired_degree.(angles) : QM.continuous_desired_degree.(angles)

    mesh = RQ.quad_mesh(boundary_pts, algorithm=quad_alg)
    num_vertices = size(mesh.p, 2)
    is_geometric_vertex = falses(num_vertices)
    is_geometric_vertex[1:poly_degree] .= true

    mesh = QM.QuadMesh(mesh.p, mesh.t, is_geometric_vertex = is_geometric_vertex)

    mask = .![trues(poly_degree); falses(mesh.num_vertices - poly_degree)]
    mask = mask .& mesh.vertex_on_boundary[mesh.active_vertex]

    d0 = [bdry_d0; fill(4, mesh.num_vertices - poly_degree)]
    d0[mask] .= 3

    p = QM.active_vertex_coordinates(mesh)
    t = QM.active_quad_connectivity(mesh)

    return p, t, d0
end

polygon_degree = rand(10:20)
p, t, d0 = initialize_random_mesh(polygon_degree)
fig, ax = PQ.plot_mesh(p,t)
fig