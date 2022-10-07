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




q = QM.make_connectivity(2)
edges, bndix = QM.all_edges(q)
test_edges = [1 1 2 2 3 4 4 5 5 6 7 8
              2 4 3 5 6 5 7 6 8 9 8 9]
@test allequal(test_edges, edges)
test_bndix = [1,2,3,5,7,10,11,12]
@test allequal(test_bndix, bndix)

degrees = QM.vertex_degrees(edges, 9)
test_degrees = [2,3,2,3,4,3,2,3,2]
@test allequal(test_degrees, degrees)


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


mesh = QM.square_mesh(2, quad_buffer = 4, vertex_buffer = 9, growth_factor = 2)
new_idx = QM.insert_vertex!(mesh, [0.25, 0.5], 3, false)
@test new_idx == 10
@test QM.vertex_buffer(mesh) == 18
@test QM.number_of_vertices(mesh) == 10
testvertices = [
    0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0 0.25
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0 0.5
]
@test allequal(testvertices, mesh.vertices[:,1:10])
@test QM.quad_buffer(mesh) == 4
@test !QM.vertex_on_boundary(mesh, 10)
@test QM.is_active_vertex(mesh, 10)

new_idx = QM.insert_quad!(mesh, [10,4,5,6], [1,3,4,2], [2, 4, 4, 2])
@test new_idx == 5
@test QM.quad_buffer(mesh) == 8
@test QM.number_of_quads(mesh) == 5

testconn = [
    1 2 4 5 10
    4 5 7 8 4
    5 6 8 9 5
    2 3 5 6 6
]
@test allequal(mesh.connectivity[:,1:5], testconn)

test_q2q = [
    0 1 0 3 1
    3 4 0 0 3
    2 0 4 0 4
    0 0 1 2 2
]
@test allequal(mesh.q2q[:,1:5], test_q2q)

test_e2e = [
    0 3 0 3 2
    4 4 0 0 4
    1 0 1 0 4
    0 0 2 2 2
]
@test allequal(mesh.e2e[:,1:5], test_e2e)
@test QM.is_active_quad(mesh, 5)


vertices = QM.make_vertices(3)
conn = QM.make_connectivity(2)
q2q = QM.make_q2q(2)
e2e = QM.make_e2e(2)
mesh = QM.QuadMesh(vertices, conn, q2q, e2e)

test_degree = [2, 3, 2, 3, 4, 3, 2, 3, 2]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)
test_on_boundary = fill(true, 9)
test_on_boundary[5] = false
@test allequal(mesh.vertex_on_boundary[mesh.active_vertex], test_on_boundary)

conn = QM.make_connectivity(3)
edges, bndix = QM.all_edges(conn)
bnd_nodes = sort!(unique(vec(edges[:,bndix])))
test_bnd_nodes = [1,2,3,4,5,8,9,12,13,14,15,16]
@test allequal(bnd_nodes, test_bnd_nodes)


mesh = QM.square_mesh(2)
v1 = mesh.vertices
QM.averagesmoothing!(mesh)