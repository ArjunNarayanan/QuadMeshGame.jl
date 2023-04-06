# using Revise
using QuadMeshGame
using Test
include("useful_routines.jl")

QM = QuadMeshGame



##############################################################################################################################
# Testing quad reindexing
vertices = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
connectivity = zeros(Int,4,10)
connectivity[:,9] .= [1,3,4,2]
connectivity[:,10] .= [3,5,6,4]
q2q = zeros(Int,4,10)
q2q[:,9] .= [0,10,0,0]
q2q[:,10] .= [0,0,0,9]
e2e = zeros(Int,4,10)
e2e[:,9] .= [0,4,0,0]
e2e[:,10] .= [0,0,0,2]
degree = [2,2,3,3,2,2]
vertex_on_boundary = trues(6)
active_vertex = trues(6)
active_quad = falses(10)
active_quad[[9,10]] .= true
num_vertices = 6
num_quads = 2
new_vertex_pointer = 7
new_quad_pointer = 11
growth_factor = 2
is_geometric_vertex = trues(6)

mesh = QM.QuadMesh(
    vertices, 
    connectivity, 
    q2q, 
    e2e, 
    degree, 
    vertex_on_boundary, 
    active_vertex, 
    active_quad,
    num_vertices, 
    num_quads, 
    new_vertex_pointer, 
    new_quad_pointer, 
    growth_factor,
    is_geometric_vertex
)

QM.reindex_quads!(mesh)

@test QM.quad_buffer(mesh) == 4
@test QM.number_of_quads(mesh) == 2
@test QM.number_of_vertices(mesh) == 6

test_vertices = vertices
@test allequal(test_vertices, mesh.vertices)

test_connectivity = zeros(Int,4,4)
test_connectivity[:,1] = [1,3,4,2]
test_connectivity[:,2] = [3,5,6,4]
@test allequal(test_connectivity, mesh.connectivity)

test_q2q = zeros(Int,4,4)
test_q2q[:,1] = [0,2,0,0]
test_q2q[:,2] = [0,0,0,1]
@test allequal(mesh.q2q, test_q2q)

test_e2e = zeros(Int,4,4)
test_e2e[:,1] = [0,4,0,0]
test_e2e[:,2] = [0,0,0,2]
@test allequal(mesh.e2e, test_e2e)

test_degree = [2,2,3,3,2,2]
@test allequal(mesh.degree, test_degree)

@test allequal(mesh.vertex_on_boundary, vertex_on_boundary)
@test allequal(mesh.active_vertex, active_vertex)
@test allequal(mesh.is_geometric_vertex, is_geometric_vertex)

test_active_quad = falses(4)
test_active_quad[[1,2]] .= true
@test allequal(mesh.active_quad, test_active_quad)

@test mesh.num_vertices == 6
@test mesh.num_quads == 2
@test mesh.new_vertex_pointer == 7
@test mesh.new_quad_pointer == 3
@test mesh.growth_factor == 2

##############################################################################################################################


##############################################################################################################################
# Testing vertex reindexing
vertices = zeros(2,15)
vertices[:,10:15] = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
connectivity = zeros(Int,4,10)
connectivity[:,9] .= [10,12,13,11]
connectivity[:,10] .= [12,14,15,13]
q2q = zeros(Int,4,10)
q2q[:,9] .= [0,10,0,0]
q2q[:,10] .= [0,0,0,9]
e2e = zeros(Int,4,10)
e2e[:,9] .= [0,4,0,0]
e2e[:,10] .= [0,0,0,2]
degree = zeros(Int,15)
degree[10:15] = [2,2,3,3,2,2]
vertex_on_boundary = falses(15)
vertex_on_boundary[10:15] .= true
active_vertex = falses(15)
active_vertex[10:15] .= true
active_quad = falses(10)
active_quad[[9,10]] .= true
num_vertices = 6
num_quads = 2
new_vertex_pointer = 16
new_quad_pointer = 11
growth_factor = 2
is_geometric_vertex = falses(15)
is_geometric_vertex[10:15] .= true

mesh = QM.QuadMesh(
    vertices, 
    connectivity, 
    q2q, 
    e2e, 
    degree, 
    vertex_on_boundary, 
    active_vertex, 
    active_quad,
    num_vertices, 
    num_quads, 
    new_vertex_pointer, 
    new_quad_pointer, 
    growth_factor,
    is_geometric_vertex
)

QM.reindex_vertices!(mesh)

@test QM.vertex_buffer(mesh) == 12
@test QM.number_of_vertices(mesh) == 6
@test QM.quad_buffer(mesh) == 10
@test QM.number_of_quads(mesh) == 2

vertices = zeros(2,12)
vertices[:,1:6] = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
@test allequal(vertices, mesh.vertices)

connectivity = zeros(Int,4,10)
connectivity[:,9] .= [1,3,4,2]
connectivity[:,10] .= [3,5,6,4]
@test allequal(connectivity, mesh.connectivity)

q2q = zeros(Int,4,10)
q2q[:,9] .= [0,10,0,0]
q2q[:,10] .= [0,0,0,9]
@test allequal(q2q, mesh.q2q)

e2e = zeros(Int,4,10)
e2e[:,9] .= [0,4,0,0]
e2e[:,10] .= [0,0,0,2]
@test allequal(mesh.e2e, e2e)

test_degree = zeros(Int,12)
test_degree[1:6] = [2,2,3,3,2,2]
@test allequal(mesh.degree, test_degree)

vertex_on_boundary = falses(12)
vertex_on_boundary[1:6] .= true
@test allequal(vertex_on_boundary, mesh.vertex_on_boundary)

is_geometric_vertex = falses(12)
is_geometric_vertex[1:6] .= true
@test allequal(mesh.is_geometric_vertex, is_geometric_vertex)

active_vertex = falses(12)
active_vertex[1:6] .= true
@test allequal(mesh.active_vertex, active_vertex)

active_quad = falses(10)
active_quad[[9,10]] .= true
@test allequal(active_quad, mesh.active_quad)

@test mesh.num_vertices == 6
@test mesh.num_quads == 2
@test mesh.new_vertex_pointer == 7
@test mesh.new_quad_pointer == 11
@test mesh.growth_factor == 2
##############################################################################################################################







##############################################################################################################################
# Testing both vertex and quad reindexing
vertices = zeros(2,15)
vertices[:,10:15] = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
connectivity = zeros(Int,4,10)
connectivity[:,9] .= [10,12,13,11]
connectivity[:,10] .= [12,14,15,13]
q2q = zeros(Int,4,10)
q2q[:,9] .= [0,10,0,0]
q2q[:,10] .= [0,0,0,9]
e2e = zeros(Int,4,10)
e2e[:,9] .= [0,4,0,0]
e2e[:,10] .= [0,0,0,2]
degree = zeros(Int,15)
degree[10:15] = [2,2,3,3,2,2]
vertex_on_boundary = falses(15)
vertex_on_boundary[10:15] .= true
active_vertex = falses(15)
active_vertex[10:15] .= true
active_quad = falses(10)
active_quad[[9,10]] .= true
num_vertices = 6
num_quads = 2
new_vertex_pointer = 16
new_quad_pointer = 11
growth_factor = 2
is_geometric_vertex = falses(15)
is_geometric_vertex[10:15] .= true

mesh = QM.QuadMesh(
    vertices, 
    connectivity, 
    q2q, 
    e2e, 
    degree, 
    vertex_on_boundary, 
    active_vertex, 
    active_quad,
    num_vertices, 
    num_quads, 
    new_vertex_pointer, 
    new_quad_pointer, 
    growth_factor,
    is_geometric_vertex
)

QM.reindex_vertices!(mesh)
QM.reindex_quads!(mesh)

@test QM.quad_buffer(mesh) == 4
@test QM.vertex_buffer(mesh) == 12
@test QM.number_of_quads(mesh) == 2
@test QM.number_of_vertices(mesh) == 6

vertices = zeros(2,12)
vertices[:,1:6] = [0. 0. 1. 1. 2. 2.
            0. 1. 0. 1. 0. 1.]
@test allequal(vertices, mesh.vertices)

test_connectivity = zeros(Int,4,4)
test_connectivity[:,1] = [1,3,4,2]
test_connectivity[:,2] = [3,5,6,4]
@test allequal(test_connectivity, mesh.connectivity)

test_q2q = zeros(Int,4,4)
test_q2q[:,1] = [0,2,0,0]
test_q2q[:,2] = [0,0,0,1]
@test allequal(mesh.q2q, test_q2q)

test_e2e = zeros(Int,4,4)
test_e2e[:,1] = [0,4,0,0]
test_e2e[:,2] = [0,0,0,2]
@test allequal(mesh.e2e, test_e2e)

test_degree = zeros(Int,12)
test_degree[1:6] = [2,2,3,3,2,2]
@test allequal(mesh.degree, test_degree)

vertex_on_boundary = falses(12)
vertex_on_boundary[1:6] .= true
@test allequal(vertex_on_boundary, mesh.vertex_on_boundary)

is_geometric_vertex = falses(12)
is_geometric_vertex[1:6] .= true
@test allequal(is_geometric_vertex, mesh.is_geometric_vertex)

active_vertex = falses(12)
active_vertex[1:6] .= true
@test allequal(mesh.active_vertex, active_vertex)

active_quad = falses(4)
active_quad[[1,2]] .= true
@test allequal(active_quad, mesh.active_quad)

@test mesh.num_vertices == 6
@test mesh.num_quads == 2
@test mesh.new_vertex_pointer == 7
@test mesh.new_quad_pointer == 3
@test mesh.growth_factor == 2
##############################################################################################################################

