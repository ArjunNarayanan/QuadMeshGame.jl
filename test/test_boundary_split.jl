# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame

maxdegree = 7
mesh = QM.square_mesh(2)
@test !QM.is_valid_boundary_split(mesh, 2, 1, maxdegree)
@test !QM.is_valid_boundary_split(mesh, 1, 1, maxdegree)
@test !QM.is_valid_boundary_split(mesh, 1, 4, maxdegree)
@test QM.is_valid_boundary_split(mesh, 2, 2, maxdegree)
@test QM.is_valid_boundary_split(mesh, 4, 1, maxdegree)

vertices = [0. 0. 1. 1. 1. 2. 2. 3.
            -1. 1. -1.5 0. 1.5 -1. 1. 0.]
connectivity = [1 3 6 4
                2 4 7 5
                4 6 8 7]
mesh = QM.QuadMesh(vertices, connectivity')

@test !QM.is_valid_boundary_split(mesh, 3, 4, maxdegree)
@test !QM.is_valid_boundary_split(mesh, 1, 3, maxdegree)


########################################################################################################
# test split operation
mesh = QM.square_mesh(2)
test_vertices = QM.active_vertex_coordinates(mesh)
@test QM.boundary_split!(mesh, 4, 1)

QM.number_of_quads(mesh) == 5
QM.number_of_vertices(mesh) == 11

test_vertices = [test_vertices [1. 1.
                                0.75 0.25]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

conn = [1 4 5 2
        2 5 6 3
        4 7 11 5
        5 10 9 6
        10 5 11 8]
@test allequal(QM.active_quad_connectivity(mesh), conn')

q2q = [0 3 2 0
       1 4 0 0
       0 0 5 1
       5 0 0 2
       4 3 0 0]
@test allequal(QM.active_quad_q2q(mesh), q2q')

e2e = [0 4 1 0
       3 4 0 0 
       0 0 2 2
       1 0 0 2
       1 3 0 0]
@test allequal(QM.active_quad_e2e(mesh), e2e')

degree = [2,3,2,3,5,3,2,2,2,3,3]
@test allequal(QM.active_vertex_degrees(mesh), degree)

on_boundary = trues(11)
on_boundary[5] = false
@test allequal(QM.active_vertex_on_boundary(mesh), on_boundary)