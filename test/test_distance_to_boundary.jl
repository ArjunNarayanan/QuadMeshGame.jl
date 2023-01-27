# using Revise
using Test
using QuadMeshGame
QM = QuadMeshGame
include("useful_routines.jl")

mesh = QM.square_mesh(2)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1, QM.vertex_buffer(mesh))
test_distances[[1,2,3,4,6,7,8,9]] .= 0
test_distances[5] = 1
@test allequal(distances, test_distances)

mesh = QM.square_mesh(3)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1,QM.vertex_buffer(mesh))
test_distances[[1,2,3,4,5,8,9,12,13,14,15,16]] .= 0
test_distances[[6,7,10,11]] .= 1
@test allequal(distances, test_distances)


mesh = QM.square_mesh(4)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1, QM.vertex_buffer(mesh))
test_distances[[1,2,3,4,5,6,10,11,15,16,20,21,22,23,24,25]] .= 0
test_distances[[7,8,9,12,13,14,17,18,19]] .= 1
test_distances[13] = 2
@test allequal(distances, test_distances)

@test QM.collapse!(mesh, 1, 3)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1, QM.vertex_buffer(mesh))
test_distances[[7,2,3,4,5,6,10,11,15,16,20,21,22,23,24,25]] .= 0
test_distances[[8,9,12,14,17,18,19]] .= 1
test_distances[13] = 2
@test allequal(test_distances, distances)

@test QM.split!(mesh, 7, 2)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1, QM.vertex_buffer(mesh))
test_distances[[7,2,3,4,5,6,10,11,15,16,20,21,22,23,24,25]] .= 0
test_distances[[8,9,12,14,17,18,19]] .= 1
test_distances[13] = 2
test_distances[26] = 2
@test allequal(distances, test_distances)

@test QM.boundary_split!(mesh, 4, 2)
distances = QM.compute_distance_to_boundary(mesh)
test_distances = fill(-1, QM.vertex_buffer(mesh))
test_distances[[7,2,3,4,5,6,10,11,15,16,20,21,22,23,24,25,27,28]] .= 0
test_distances[[8,9,12,14,17,18,19]] .= 1
test_distances[13] = 2
test_distances[26] = 2
@test allequal(distances, test_distances)