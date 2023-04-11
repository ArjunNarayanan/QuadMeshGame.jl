# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame



########################################################################################################################
# Check valid cleanup
mesh = QM.square_mesh(2)
is_geometric_vertex = falses(9)
is_geometric_vertex[[1,3,7,9]] .= true
mesh = QM.QuadMesh(QM.active_vertex_coordinates(mesh),
                   QM.active_quad_connectivity(mesh),
                   is_geometric_vertex=is_geometric_vertex)


@test !QM.is_valid_cleanup(mesh, 1, 1, 10)
@test QM.is_valid_cleanup(mesh, 1, 2, 10)
@test !QM.is_valid_cleanup(mesh, 1, 3, 10)
@test !QM.is_valid_cleanup(mesh, 1, 4, 10)

@test QM.is_valid_cleanup(mesh, 2, 1, 10)
@test !QM.is_valid_cleanup(mesh, 2, 2, 10)
@test !QM.is_valid_cleanup(mesh, 2, 3, 10)
@test !QM.is_valid_cleanup(mesh, 2, 4, 10)

@test !QM.is_valid_cleanup(mesh, 3, 1, 10)
@test !QM.is_valid_cleanup(mesh, 3, 2, 10)
@test QM.is_valid_cleanup(mesh, 3, 3, 10)
@test !QM.is_valid_cleanup(mesh, 3, 4, 10)

@test !QM.is_valid_cleanup(mesh, 4, 1, 10)
@test !QM.is_valid_cleanup(mesh, 4, 2, 10)
@test !QM.is_valid_cleanup(mesh, 4, 3, 10)
@test QM.is_valid_cleanup(mesh, 4, 4, 10)
########################################################################################################################

########################################################################################################################
# check valid cleanup handles boundary vertices along path

vertices = [0.0 0.0 0.0 1.0 1.0 1.0 2.0 2.0
            0.0 1.0 2.0 0.0 1.0 2.0 0.0 1.0]
connectivity = [1 4 5 2
                2 5 6 3
                4 7 8 5]
is_geometric_vertex = falses(8)
is_geometric_vertex[[1,3,7]] .= true
mesh = QM.QuadMesh(vertices, connectivity', is_geometric_vertex = is_geometric_vertex)

@test !QM.is_valid_cleanup(mesh, 1, 1, 10)
@test !QM.is_valid_cleanup(mesh, 1, 2, 10)
@test !QM.is_valid_cleanup(mesh, 1, 3, 10)
@test !QM.is_valid_cleanup(mesh, 1, 4, 10)

@test !QM.is_valid_cleanup(mesh, 2, 1, 10)
@test !QM.is_valid_cleanup(mesh, 2, 2, 10)
@test !QM.is_valid_cleanup(mesh, 2, 3, 10)
@test !QM.is_valid_cleanup(mesh, 2, 4, 10)

@test !QM.is_valid_cleanup(mesh, 3, 1, 10)
@test !QM.is_valid_cleanup(mesh, 3, 2, 10)
@test !QM.is_valid_cleanup(mesh, 3, 3, 10)
@test !QM.is_valid_cleanup(mesh, 3, 4, 10)
########################################################################################################################


########################################################################################################################
# check valid cleanup handles bigger example with interior geometric vertex 

mesh = QM.square_mesh(3)
is_geometric_vertex = falses(16)
is_geometric_vertex[[1,4,11,13,16]] .= true
mesh = QM.QuadMesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    is_geometric_vertex=is_geometric_vertex
)

@test !QM.is_valid_cleanup(mesh, 1, 1, 10)
@test QM.is_valid_cleanup(mesh, 1, 2, 10)
# test maxsteps condition
@test !QM.is_valid_cleanup(mesh, 1, 2, 1)
@test !QM.is_valid_cleanup(mesh, 1, 3, 10)
@test !QM.is_valid_cleanup(mesh, 1, 4, 10)

@test QM.is_valid_cleanup(mesh, 2, 1, 10)
@test !QM.is_valid_cleanup(mesh, 2, 1, 1)
@test !QM.is_valid_cleanup(mesh, 2, 2, 10)
@test !QM.is_valid_cleanup(mesh, 2, 3, 10)
@test !QM.is_valid_cleanup(mesh, 2, 4, 10)

@test !QM.is_valid_cleanup(mesh, 3, 1, 10)
@test !QM.is_valid_cleanup(mesh, 3, 2, 10)
@test !QM.is_valid_cleanup(mesh, 3, 3, 10)
@test !QM.is_valid_cleanup(mesh, 3, 4, 10)

@test !QM.is_valid_cleanup(mesh, 4, 1, 10)
@test !QM.is_valid_cleanup(mesh, 4, 2, 10)
@test !QM.is_valid_cleanup(mesh, 4, 3, 10)
@test !QM.is_valid_cleanup(mesh, 4, 4, 10)

@test !QM.is_valid_cleanup(mesh, 5, 1, 10)
@test !QM.is_valid_cleanup(mesh, 5, 2, 10)
@test !QM.is_valid_cleanup(mesh, 5, 3, 10)
@test !QM.is_valid_cleanup(mesh, 5, 4, 10)

@test !QM.is_valid_cleanup(mesh, 6, 1, 10)
@test !QM.is_valid_cleanup(mesh, 6, 2, 10)
@test !QM.is_valid_cleanup(mesh, 6, 3, 10)
@test QM.is_valid_cleanup(mesh, 6, 4, 10)

@test !QM.is_valid_cleanup(mesh, 7, 1, 10)
@test !QM.is_valid_cleanup(mesh, 7, 2, 10)
@test QM.is_valid_cleanup(mesh, 7, 3, 10)
@test !QM.is_valid_cleanup(mesh, 7, 4, 10)

@test !QM.is_valid_cleanup(mesh, 8, 1, 10)
@test !QM.is_valid_cleanup(mesh, 8, 2, 10)
@test !QM.is_valid_cleanup(mesh, 8, 3, 10)
@test !QM.is_valid_cleanup(mesh, 8, 4, 10)

@test !QM.is_valid_cleanup(mesh, 9, 1, 10)
@test !QM.is_valid_cleanup(mesh, 9, 2, 10)
@test !QM.is_valid_cleanup(mesh, 9, 3, 10)
@test !QM.is_valid_cleanup(mesh, 9, 4, 10)
########################################################################################################################


########################################################################################################################
# test step cleanup merge single step

vertices = [
    0.0 0.0 1.0 1.0 2.0 2.0
    0.0 1.0 0.0 1.0 0.0 1.0
]
connectivity = [
    1 3 4 2
    3 5 6 4
]
is_geometric_vertex = falses(6)
is_geometric_vertex[[1,2,5,6]] .= true
mesh = QM.QuadMesh(vertices, connectivity', is_geometric_vertex=is_geometric_vertex)

@test QM.is_valid_cleanup(mesh, 1, 2, 10)
# test throws assertion error if nbr quad in merge has a higher index than self
@test_throws AssertionError QM._step_cleanup_merge!(mesh, 1, 2)

tracker = QM.Tracker()
@test QM.step_cleanup_merge!(mesh, 1, 2, tracker)

@test allequal(tracker.new_vertex_ids, [3])
@test allequal(tracker.on_boundary, [true])

QM.delete_vertex!(mesh, 4)

@test QM.number_of_vertices(mesh) == 4
@test QM.number_of_quads(mesh) == 1

test_vertices = [
    0.0 0.0 2.0 2.0
    0.0 1.0 0.0 1.0
]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)
test_connectivity = reshape([1,5,6,2], 4, 1)
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity)
test_q2q = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_q2q(mesh), test_q2q)
test_e2e = copy(test_q2q)
@test allequal(QM.active_quad_e2e(mesh), test_e2e)
test_degree = [2,2,2,2]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)
test_vertex_on_boundary = trues(4)
@test allequal(QM.active_vertex_on_boundary(mesh), test_vertex_on_boundary)
@test mesh.new_vertex_pointer == 7
@test mesh.new_quad_pointer == 3
########################################################################################################################


########################################################################################################################
# test multistep merge


mesh = QM.square_mesh(2)
original_vertices = QM.active_vertex_coordinates(mesh)
is_geometric_vertex = falses(9)
is_geometric_vertex[[1,3,7,9]] .= true
mesh = QM.QuadMesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    is_geometric_vertex=is_geometric_vertex
)

@test QM.is_valid_cleanup(mesh, 1, 2, 5)

tracker = QM.Tracker()
@test QM.step_cleanup_merge!(mesh, 1, 2, tracker)

@test allequal(tracker.new_vertex_ids, [4])
@test allequal(tracker.on_boundary, [true])

@test QM.number_of_quads(mesh) == 3
@test QM.number_of_vertices(mesh) == 8

test_vertices = original_vertices[:,[1,2,3,5,6,7,8,9]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = [
    2 5 6 3
    1 7 8 2
    5 8 9 6
]
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity')

test_q2q = [
    3 4 0 0
    0 0 4 0
    3 0 0 2
]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [
    3 4 0 0
    0 0 1 0
    3 0 0 2
]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')

@test QM.step_cleanup_merge!(mesh, 2, 2, tracker)

@test allequal(tracker.new_vertex_ids, [4,5])
@test allequal(tracker.on_boundary, [true,false])

QM.delete_vertex!(mesh, 6)

@test QM.number_of_quads(mesh) == 2
@test QM.number_of_vertices(mesh) == 6

test_vertices = original_vertices[:,[1,2,3,7,8,9]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = [
    1 7 8 2
    2 8 9 3
]
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity')

test_q2q = [
    0 0 4 0
    3 0 0 0
]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [
    0 0 1 0
    3 0 0 0
]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')
########################################################################################################################


########################################################################################################################
# test cleanup path

mesh = QM.square_mesh(2)
original_vertices = QM.active_vertex_coordinates(mesh)
is_geometric_vertex = falses(9)
is_geometric_vertex[[1,3,7,9]] .= true
mesh = QM.QuadMesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    is_geometric_vertex=is_geometric_vertex
)

tracker = QM.Tracker()
@test QM.cleanup_path!(mesh, 1, 2, 5, tracker)

@test allequal(tracker.new_vertex_ids, [4,5,6])
@test allequal(tracker.on_boundary, [true,false,true])

@test QM.number_of_quads(mesh) == 2
@test QM.number_of_vertices(mesh) == 6

test_vertices = original_vertices[:,[1,2,3,7,8,9]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = [
    1 7 8 2
    2 8 9 3
]
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity')

test_q2q = [
    0 0 4 0
    3 0 0 0
]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')

test_e2e = [
    0 0 1 0
    3 0 0 0
]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')

test_degree = [2,3,2,2,3,2]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)

test_vertex_on_boundary = trues(6)
@test allequal(QM.active_vertex_on_boundary(mesh), test_vertex_on_boundary)
@test mesh.new_vertex_pointer == 10
@test mesh.new_quad_pointer == 5

@test QM.is_valid_cleanup(mesh, 4, 1, 5)

@test QM.cleanup_path!(mesh, 4, 1, 5, tracker)

@test allequal(tracker.new_vertex_ids, [4,5,6,2,8])
@test allequal(tracker.on_boundary, [true,false,true,true,true])

@test QM.number_of_quads(mesh) == 1
@test QM.number_of_vertices(mesh) == 4

test_vertices = original_vertices[:,[1,3,7,9]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = reshape([1,7,9,3], 4, 1)
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity)

test_q2q = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_q2q(mesh), test_q2q)

test_e2e = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_e2e(mesh), test_e2e)

########################################################################################################################



########################################################################################################################
# test cleanup mesh

mesh = QM.square_mesh(2)
original_vertices = QM.active_vertex_coordinates(mesh)
is_geometric_vertex = falses(9)
is_geometric_vertex[[1,3,7,9]] .= true
mesh = QM.QuadMesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh),
    is_geometric_vertex=is_geometric_vertex
)

tracker = QM.Tracker()
QM.cleanup_mesh!(mesh, 5, tracker)

@test allequal(tracker.new_vertex_ids, [4,5,6,8,2])
@test allequal(tracker.on_boundary, [true,false,true,true,true])

@test QM.number_of_quads(mesh) == 1
@test QM.number_of_vertices(mesh) == 4

test_vertices = original_vertices[:,[1,3,7,9]]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = reshape([1,7,9,3], 4, 1)
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity)

test_q2q = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_q2q(mesh), test_q2q)

test_e2e = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_e2e(mesh), test_e2e)

test_degree = [2,2,2,2]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)

test_vertex_on_boundary = trues(4)
@test allequal(QM.active_vertex_on_boundary(mesh), test_vertex_on_boundary)
@test mesh.new_vertex_pointer == 10
@test mesh.new_quad_pointer == 5
########################################################################################################################



########################################################################################################################
# more complex example

vertices = QM.make_vertices(5)
connectivity = [
    7 12 13 8
    13 18 19 14
    3 8 9 4
    17 22 23 18
    1 6 7 2
    14 19 20 15
    11 16 17 12
    4 9 10 5
    6 11 12 7
    12 17 18 13
    19 24 25 20
    18 23 24 19
    16 21 22 17
    8 13 14 9
    9 14 15 10
    2 7 8 3
]
is_geometric_vertex = falses(25)
is_geometric_vertex[[1,5,21,25]] .= true
mesh = QM.QuadMesh(vertices, connectivity', is_geometric_vertex=is_geometric_vertex)

tracker = QM.Tracker()
QM.cleanup_mesh!(mesh, 10, tracker)

@test allequal(tracker.new_vertex_ids, [3,8,13,18,23,6,7,9,10,15,14,12,11,16,17,19,20,22,2,4,24])
@test allequal(tracker.on_boundary, [true,false,false,false,true,true,false,false,true,true,false,false,true,true,false,false,true,true,true,true,true])

@test QM.number_of_quads(mesh) == 1
@test QM.number_of_vertices(mesh) == 4

test_vertices = [
    0.0 0.0 1.0 1.0
    0.0 1.0 0.0 1.0
]
@test allequal(QM.active_vertex_coordinates(mesh), test_vertices)

test_connectivity = reshape([1,21,25,5],4,1)
@test allequal(QM.active_quad_connectivity(mesh), test_connectivity)

test_q2q = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_q2q(mesh), test_q2q)

test_e2e = reshape([0,0,0,0],4,1)
@test allequal(QM.active_quad_e2e(mesh), test_e2e)

test_degree = [2,2,2,2]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)

test_vertex_on_boundary = trues(4)
@test allequal(QM.active_vertex_on_boundary(mesh), test_vertex_on_boundary)
@test mesh.new_vertex_pointer == 26
@test mesh.new_quad_pointer == 17

########################################################################################################################