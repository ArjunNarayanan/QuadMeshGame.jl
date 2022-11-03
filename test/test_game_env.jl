# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")

QM = QuadMeshGame


@test QM.enclosed_angle([1,0],[0,1]) == 90
@test QM.enclosed_angle([0,1],[-1,-1]) == 135
@test QM.enclosed_angle([1,1],[1,-1]) == 270
@test QM.enclosed_angle([1,0],[1,-eps()]) == 360

@test all(QM.desired_degree.(0:120) .== 2)
@test all(QM.desired_degree.(121:216) .== 3)
@test all(QM.desired_degree.(217:308) .== 4)
@test all(QM.desired_degree.(309:360) .== 5)

mesh = QM.square_mesh(2)
d0 = copy(mesh.degree[mesh.active_vertex])
@test QM.left_flip!(mesh, 1, 2)
env = QM.GameEnv(mesh, d0, 10)

@test env.num_actions == 0
@test env.max_actions == 10
@test allequal(d0, env.desired_degree[mesh.active_vertex])

test_vs = [0,1,0,-1,-1,0,1,0,0]
@test allequal(QM.active_vertex_scores(env), test_vs)
@test env.current_score == 4
@test env.opt_score == 0
@test env.initial_score == 4
@test env.reward == 0
@test !env.is_terminated


mesh = QM.square_mesh(2, quad_buffer=4, vertex_buffer=9)
pairs = QM.make_edge_pairs(mesh)
test_pairs = [17,12,5,17,3,16,17,17,17,17,13,2,11,17,17,6]
@test allequal(pairs, test_pairs)

@test QM.left_flip!(mesh, 2, 2)
pairs = QM.make_edge_pairs(mesh)
test_pairs = [17,12,8,17,11,16,17,3,17,17,5,2,17,17,17,6]
@test allequal(pairs, test_pairs)

mesh = QM.square_mesh(2, quad_buffer = 4, vertex_buffer=9)
x = reshape(mesh.connectivity, 1, :)
cx = QM.cycle_edges(x)

test_cx1 = [1 4 5 2
            4 5 2 1
            5 2 1 4
            2 1 4 5]
test_cx2 = [2 5 6 3
            5 6 3 2
            6 3 2 5
            3 2 5 6]
test_cx3 = [4 7 8 5
            7 8 5 4
            8 5 4 7
            5 4 7 8]
test_cx4 = [5 8 9 6
            8 9 6 5
            9 6 5 8
            6 5 8 9]
test_cx = cat(test_cx1, test_cx2, test_cx3, test_cx4, dims=2)
@test allequal(cx, test_cx)


mesh = QM.square_mesh(3, vertex_buffer=16, quad_buffer=9)
template = QM.make_template(mesh)

test_elem_5_1 = [6,10,11,7,5,9,14,15,12,8,3,2,2,1,0,0,13,14,9,13,0,0,16,12,15,16,0,0,4,3,8,4,0,0,1,5]
test_elem_5_2 = [10,11,7,6,14,15,12,8,3,2,5,9,9,13,0,0,16,12,15,16,0,0,4,3,8,4,0,0,1,5,2,1,0,0,13,14]
test_elem_5_3 = [11,7,6,10,12,8,3,2,5,9,14,15,15,16,0,0,4,3,8,4,0,0,1,5,2,1,0,0,13,14,9,13,0,0,16,12]
test_elem_5_4 = [7,6,10,11,3,2,5,9,14,15,12,8,8,4,0,0,1,5,2,1,0,0,13,14,9,13,0,0,16,12,15,16,0,0,4,3]

@test allequal(template[:,17], test_elem_5_1)
@test allequal(template[:,18], test_elem_5_2)
@test allequal(template[:,19], test_elem_5_3)
@test allequal(template[:,20], test_elem_5_4)


mesh = QM.square_mesh(2)
env = QM.GameEnv(mesh, mesh.degree[mesh.active_vertex], 10)
QM.step_split!(env, 1, 3)

@test env.desired_degree[10] == 4

template_5_1 = [10,4,5,6,2,1,7,8,8,9,3,2,6,3,0,0,0,0,0,0,0,0,9,6,4,7,0,0,0,0,0,0,0,0,1,4]
template_5_2 = [4,5,6,10,7,8,8,9,3,2,2,1,0,0,0,0,9,6,4,7,0,0,0,0,0,0,0,0,1,4,6,3,0,0,0,0]
@test allequal(env.template[:,17], template_5_1)
@test allequal(env.template[:,18], template_5_2)

template_3_2 = [7,8,5,4,0,0,9,6,6,10,0,0,0,0,0,0,0,0,0,0,0,0,10,4,8,9,3,2,2,1,0,0,0,0,0,0]
@test allequal(env.template[:,10], template_3_2)

QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)

test_conn = [6 10 4 5
             2 10 6 3
             4 7 8 5
             5 8 9 6
             4 10 2 1]
@test allequal(QM.active_quad_connectivity(env.mesh), test_conn')

@test QM.is_valid_collapse(mesh, 1, 2, 7)
QM.step_collapse!(env, 1, 2)

template_5_1 = [4,10,2,1,7,8,6,3,0,0,0,0,0,0,0,0,9,6,8,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
@test allequal(template_5_1, env.template[:,17])

test_desired_degree = [[2,3,2,3,0,3,2,3,2,4]; zeros(Int, QM.vertex_buffer(env.mesh) - 10)]
@test allequal(test_desired_degree, env.desired_degree)



mesh = QM.square_mesh(2)
d0 = deepcopy(mesh.degree[mesh.active_vertex])
QM.left_flip!(mesh, 1, 2)
env = QM.GameEnv(mesh, d0, 4)
QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0
@test env.num_actions == 1

QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0

QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0

QM.step_nothing!(env)
@test env.is_terminated
@test env.reward == 0


############################################################################################################
# Test reindex game env
mesh = QM.square_mesh(2)
env = QM.GameEnv(mesh, mesh.degree[mesh.active_vertex], 10)
QM.step_split!(env, 1, 3)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_collapse!(env, 1, 2)

QM.reindex_game_env!(env)

connectivity = [2 9 5 3
                4 6 7 9
                9 7 8 5
                4 9 2 1]
@test allequal(QM.active_quad_connectivity(env.mesh), connectivity')
q2q = [4 3 0 0
       0 0 3 4
       2 0 0 1
       2 1 0 0]
@test allequal(QM.active_quad_q2q(env.mesh), q2q')
e2e = [2 4 0 0
       0 0 1 1
       3 0 0 2
       4 1 0 0]
@test allequal(QM.active_quad_e2e(env.mesh), e2e')
d0 = [2,3,2,3,3,2,3,2,4]
@test allequal(QM.active_vertex_desired_degree(env), d0)
############################################################################################################


############################################################################################################
# TEST COLLAPSING BOUNDARY QUAD
mesh = QM.square_mesh(2)
desired_degree = deepcopy(mesh.degree[mesh.active_vertex])
env = QM.GameEnv(mesh, desired_degree, 5)
QM.step_collapse!(env, 1, 3)
degree = [2,2,2,4,3,2,3,2]
@test allequal(QM.active_vertex_degrees(env.mesh), degree)
test_d0 = [0,3,2,3,2,3,2,3,2]
@test allequal(env.desired_degree[1:9], test_d0)
on_boundary = trues(8)
@test allequal(env.mesh.vertex_on_boundary[env.mesh.active_vertex], on_boundary)
# need at least one vertex in interior for collapse
@test !QM.is_valid_collapse(mesh, 4, 1, 7)
############################################################################################################


mesh = QM.square_mesh(3, vertex_buffer=16, quad_buffer=9)
pairs = QM.make_edge_pairs(mesh)

x = reshape(mesh.connectivity, 1, :)

cx = QM.cycle_edges(x)

p1x = QM.zero_pad(cx)[:, pairs][3:end, :]
cp1x = QM.cycle_edges(p1x)

p2x = QM.zero_pad(cp1x)[:, pairs][3:end, :]
cp2x = QM.cycle_edges(p2x)

p3x = QM.zero_pad(cp2x)[:, pairs][7:end, :]
cp3x = QM.cycle_edges(p3x)