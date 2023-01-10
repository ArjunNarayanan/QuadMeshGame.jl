using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame

mesh = QM.square_mesh(2)
test_vertices = QM.active_vertex_coordinates(mesh)

@test QM.is_valid_global_split(mesh, 2, 1, 7)
tracker = QM.Tracker()
new_quad_idx = QM.insert_initial_quad_for_global_split!(mesh, 2, 1, tracker)
@test new_quad_idx == 5
@test QM.number_of_vertices(mesh) == 11
@test QM.number_of_quads(mesh) == 5

new_vert_coords = [0.5 0.5
                   0.75 0.25]
test_vertices = [test_vertices new_vert_coords]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_conn = [1 4 11 2
             2 10 6 3
             4 7 8 5
             5 8 9 6
             10 2 11 5]
@test allequal(QM.active_quad_connectivity(mesh), test_conn')
test_q2q = [0 3 5 0
            5 4 0 0
            0 0 4 1
            3 0 0 2
            2 1 3 4]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')
test_e2e = [0 4 2 0
            1 4 0 0
            0 0 1 2
            3 0 0 2
            1 3 4 4]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')
@test allequal(tracker.new_vertex_ids, [10, 11])
@test allequal(tracker.on_boundary, [false, false])

test_degrees = [2, 4, 2, 3, 3, 3, 2, 3, 2, 4, 4]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)



@test QM.is_valid_path_split(mesh, 2, 1)
QM.split_neighboring_quad_along_path!(mesh, 2, 1, tracker)
@test QM.number_of_vertices(mesh) == 12
@test QM.number_of_quads(mesh) == 6

test_vertices = [test_vertices [1.0; 0.75]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_conn = [1 4 11 2
             2 10 6 3
             4 7 8 5
             10 12 9 6
             10 2 11 5
             12 10 5 8]
@test allequal(QM.active_quad_connectivity(mesh), test_conn')

test_q2q = [0 3 5 0
            5 4 0 0
            0 0 6 1
            6 0 0 2
            2 1 3 6
            4 5 3 0]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [0 4 2 0
            1 4 0 0
            0 0 3 2
            1 0 0 2
            1 3 4 2
            1 4 3 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')


@test allequal(tracker.new_vertex_ids, [10, 11, 12])
@test allequal(tracker.on_boundary, [false, false, true])

test_degrees = [2, 4, 2, 3, 3, 3, 2, 3, 2, 4, 4, 3]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)


@test QM.is_valid_path_split(mesh, 5, 2)
QM.split_neighboring_quad_along_path!(mesh, 5, 2, tracker)
@test QM.number_of_vertices(mesh) == 13
@test QM.number_of_quads(mesh) == 7

test_vertices = [test_vertices [1.0; 0.25]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_conn = [1 4 11 2
             2 10 6 3
             11 13 8 5
             10 12 9 6
             10 2 11 5
             12 10 5 8
             13 11 4 7]
@test allequal(QM.active_quad_connectivity(mesh), test_conn')

test_q2q = [0 7 5 0
            5 4 0 0
            7 0 6 5
            6 0 0 2
            2 1 3 6
            4 5 3 0
            3 1 0 0]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [0 2 2 0
            1 4 0 0
            1 0 3 3
            1 0 0 2
            1 3 4 2
            1 4 3 0
            1 2 0 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')

@test allequal(tracker.new_vertex_ids, [10, 11, 12, 13])
@test allequal(tracker.on_boundary, [false, false, true, true])

test_degrees = [2, 4, 2, 3, 3, 3, 2, 3, 2, 4, 4, 3, 3]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)



mesh = QM.square_mesh(2)
test_vertices = QM.active_vertex_coordinates(mesh)

tracker = QM.Tracker()
@test QM.global_split!(mesh, 2, 1, tracker)

@test QM.number_of_vertices(mesh) == 13
@test QM.number_of_quads(mesh) == 7

test_vertices = [test_vertices [0.5 0.5 1.0 1.0; 0.75 0.25 0.75 0.25]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_conn = [1 4 11 2
             2 10 6 3
             11 13 8 5
             10 12 9 6
             10 2 11 5
             12 10 5 8
             13 11 4 7]
@test allequal(QM.active_quad_connectivity(mesh), test_conn')

test_q2q = [0 7 5 0
            5 4 0 0
            7 0 6 5
            6 0 0 2
            2 1 3 6
            4 5 3 0
            3 1 0 0]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [0 2 2 0
            1 4 0 0
            1 0 3 3
            1 0 0 2
            1 3 4 2
            1 4 3 0
            1 2 0 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')

@test allequal(tracker.new_vertex_ids, [10, 11, 12, 13])
@test allequal(tracker.on_boundary, [false, false, true, true])

test_degrees = [2, 4, 2, 3, 3, 3, 2, 3, 2, 4, 4, 3, 3]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)




######################################################################################################
# Larger example

mesh = QM.square_mesh(3)
tracker = QM.Tracker()
@test QM.global_split!(mesh, 2, 1, tracker)

@test QM.number_of_vertices(mesh) == 22
@test QM.number_of_quads(mesh) == 14

test_conn = [1 2 3 18 17 7 21 19 11 17 19 20 21 22
             5 17 7 21 19 11 22 20 15 2 17 19 18 21
             18 7 8 10 11 12 14 15 16 18 6 10 5 9
             2 3 4 6 7 8 10 11 12 6 10 14 9 13]
@test allequal(QM.active_quad_connectivity(mesh), test_conn)

test_q2q = [0 10 2 13 11 5 14 12 8 2 5 8 4 7
            13 5 6 7 8 9 0 0 0 1 10 11 1 13
            10 3 0 11 6 0 12 9 0 4 4 7 0 0 
            0 0 0 10 2 3 4 5 6 11 12 0 14 0 ]
@test allequal(QM.active_quad_q2q(mesh), test_q2q)

test_e2e = [0 1 3 1 1 3 1 1 3 1 1 1 1 1
            2 4 4 4 4 4 0 0 0 3 4 4 2 4
            2 1 0 3 1 0 3 1 0 4 3 3 0 0 
            0 0 0 3 2 2 2 2 2 2 2 0 2 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e)

@test allequal(tracker.new_vertex_ids, [17, 18, 19, 20, 21, 22])
@test allequal(tracker.on_boundary, [false, false, false, true, false, true])

test_degrees = [2,4,3,2,3,3,4,3,3,4,4,3,2,3,3,2,4,4,4,3,4,3]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)



######################################################################################################
# asymmetric example

vertices = [0. 0. 1. 1. 2. 2. 2. 3. 3. 3.
            0. 1. 0. 1. 0. 1. 2. 0. 1. 2.]
connectivity = [1 3 4 2
                3 5 6 4
                5 8 9 6
                6 9 10 7]
mesh = QM.QuadMesh(vertices, connectivity')

@test QM.is_valid_global_split(mesh, 3, 3, 7)
tracker = QM.Tracker()
@test QM.global_split!(mesh, 3, 3, tracker)

@test QM.number_of_vertices(mesh) == 14
@test QM.number_of_quads(mesh) == 7

test_conn = [1 3 5 12 11 13 14
             3 5 8 9 9 11 13
             13 11 9 10 12 6 4
             14 13 11 7 6 4 2]
@test allequal(QM.active_quad_connectivity(mesh), test_conn)

test_q2q = [0 0 0 5 3 2 1
            2 3 0 0 4 5 6
            7 6 5 0 0 0 0
            0 1 2 0 6 7 0]
@test allequal(QM.active_quad_q2q(mesh), test_q2q)

test_e2e = [0 0 0 2 3 3 3
            4 4 0 0 1 4 4
            1 1 1 0 0 0 0 
            0 2 2 0 2 2 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e)

@test allequal(tracker.new_vertex_ids, [11, 12, 13, 14])
@test allequal(tracker.on_boundary, [false, true, false, true])

test_degrees = [2, 2, 3, 3, 3, 3, 2, 2, 4, 2, 4, 3, 4, 3]
@test allequal(QM.active_vertex_degrees(mesh), test_degrees)




######################################################################################################
# Handling degree 3 vertices 

vertices = [0. 0. 0. 1. 1. 1. 1.5 2. 2. 2.5
            0. 1. 2. 0. 1. 2. 1. 0. 2. 1.]
connectivity = [1 4 5 2
                2 5 6 3
                4 8 7 5
                5 7 9 6
                7 8 10 9]
mesh = QM.QuadMesh(vertices, connectivity')

tracker = QM.Tracker()
@test QM.global_split!(mesh, 2, 1, tracker)

@test QM.number_of_vertices(mesh) == 17
@test QM.number_of_quads(mesh) == 11

connectivity = [1 2 12 11 13 11 13 16 15 16 17
                4 11 15 13 16 2 11 13 12 15 16
                12 6 7 9 17 12 5 7 4 8 14
                2 3 5 6 9 5 7 15 8 14 10]
@test allequal(connectivity, QM.active_quad_connectivity(mesh))

q2q = [0 6 9 7 8 2 4 5 3 8 5
       9 4 8 5 11 1 6 7 1 9 10
       6 0 7 0 0 3 3 3 0 0 0
       0 0 6 2 4 7 8 10 10 11 0]
@test allequal(q2q, QM.active_quad_q2q(mesh))

e2e = [0 1 1 1 1 1 1 1 1 4 2
       2 4 3 4 1 3 4 4 2 4 4
       2 0 3 0 0 4 3 2 0 0 0
       0 0 3 2 2 2 2 1 2 2 0]
@test allequal(e2e, QM.active_quad_e2e(mesh))


@test allequal(tracker.new_vertex_ids, [11, 12, 13, 14, 15, 16, 17])
@test allequal(tracker.on_boundary, [false, false, false, true, false, false, true])


######################################################################################################
# Check loop formation
vertices = [0. 0. 0. 1. 1. 1. 1.5 2. 2. 2.5
            0. 1. 2. 0. 1. 2. 1. 0. 2. 1.]
connectivity = [1 4 5 2
                2 5 6 3
                4 8 7 5
                5 7 9 6
                7 8 10 9]
mesh = QM.QuadMesh(vertices, connectivity')

@test !QM.check_loop_in_next_step(mesh, 2, 1, 1, 3)

vertices = [0. 0. 0. 1. 1. 1. 2. 3.
            0. 1. 2. 0. 1. 2. 1. 1.]
connectivity = [1 4 5 2
                2 5 6 3
                4 8 7 5
                5 7 8 6]
mesh = QM.QuadMesh(vertices, connectivity')
@test !QM.check_loop_in_next_step(mesh, 2, 1, 1, 3)

tracker = QM.Tracker()
QM.insert_initial_quad_for_global_split!(mesh, 2, 1, tracker)

oq, ot = QM.neighbor(mesh, 2, 1), QM.twin(mesh, 2, 1)
nq, nt = QM.neighbor(mesh, 2, QM.next(1)), QM.twin(mesh, 2, QM.next(1))
noq, not = QM.neighbor(mesh, oq, QM.previous(ot)), QM.neighbor(mesh, oq, QM.previous(ot))
noq == nq && not == nt
nnq, nnt = QM.neighbor(mesh, nq, nt), QM.twin(mesh, nq, nt)
@assert nnq == 2 && nnt == QM.next(1)

QM.is_valid_path_split(mesh, 2, 1)
QM.split_neighboring_quad_along_path!(mesh, 2, 1, tracker)
@test QM.check_loop_in_next_step(mesh, 4, 1, 1, 3)