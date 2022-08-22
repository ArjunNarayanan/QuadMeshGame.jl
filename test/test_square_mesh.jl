# using Revise
using QuadMeshGame
using Test
include("useful_routines.jl")

QM = QuadMeshGame

testvertices = [
    0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0
]
@test allequal(testvertices, QM.make_vertices(3))

conn = QM.make_connectivity(2)
testconn = [
    1 2 4 5
    4 5 7 8
    5 6 8 9
    2 3 5 6
]
@test allequal(conn, testconn)

q2q = QM.make_q2q(2)
test_q2q = [
    0 1 0 3
    3 4 0 0
    2 0 4 0
    0 0 1 2
]
@test allequal(q2q, test_q2q)

e2e = QM.make_e2e(2)
test_e2e = [
    0 3 0 3
    4 4 0 0
    1 0 1 0
    0 0 2 2
]
@test allequal(e2e, test_e2e)

d = QM.make_degree(2)
test_degree = [2, 3, 2, 3, 4, 3, 2, 3, 2]
@test allequal(d, test_degree)

on_boundary = QM.make_vertex_on_boundary(2)
test_on_boundary = fill(true, 9)
test_on_boundary[5] = false
@test allequal(on_boundary, test_on_boundary)

mesh = QM.square_mesh(2, quad_buffer = 10, vertex_buffer = 15, growth_factor = 2)

@test allequal(mesh.vertices[:, 1:9], testvertices)
@test allequal(mesh.connectivity[:, 1:4], testconn)
@test allequal(mesh.q2q[:, 1:4], test_q2q)
@test allequal(mesh.e2e[:, 1:4], test_e2e)
@test allequal(mesh.degree[1:9], test_degree)
@test allequal(mesh.vertex_on_boundary[1:9], test_on_boundary)

test_active_vertex = falses(15)
test_active_vertex[1:9] .= true
@test allequal(mesh.active_vertex, test_active_vertex)
test_active_quad = falses(10)
test_active_quad[1:4] .= true
@test allequal(mesh.active_quad, test_active_quad)

@test QM.number_of_vertices(mesh) == 9
@test QM.number_of_quads(mesh) == 4


QM.expand_vertices!(mesh)
@test size(mesh.vertices, 2) == 30
@test length(mesh.degree) == 30
@test length(mesh.vertex_on_boundary) == 30
@test length(mesh.active_vertex) == 30
@test allequal(mesh.vertices[:, 1:9], testvertices)
@test allequal(mesh.degree[1:9], test_degree)
@test allequal(mesh.active_vertex, [test_active_vertex; falses(15)])
@test mesh.num_vertices == 9

QM.expand_quad!(mesh)
@test size(mesh.connectivity, 2) == 20
@test size(mesh.q2q, 2) == 20
@test size(mesh.e2e, 2) == 20
@test length(mesh.active_quad) == 20
@test allequal(mesh.connectivity[:,1:4], testconn)
@test allequal(mesh.q2q[:,1:4], test_q2q)
@test allequal(mesh.e2e[:,1:4], test_e2e)
@test allequal(mesh.active_quad, [test_active_quad; falses(10)])
@test mesh.num_quads == 4
