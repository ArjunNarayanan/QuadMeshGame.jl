mutable struct GameEnv
    mesh::Any
    desired_degree::Any
    vertex_score::Any
    max_actions::Any
    num_actions::Any
    initial_score::Any
    current_score::Any
    opt_score::Any
    reward::Any
    is_terminated::Any
end

function check_terminated(num_actions, max_actions, current_score, opt_score)
    return num_actions >= max_actions || current_score <= opt_score
end

function check_terminated(env)
    return check_terminated(
        env.num_actions,
        env.max_actions,
        env.current_score,
        env.opt_score,
    )
end

function _is_initial_mesh(mesh)
    nv = number_of_vertices(mesh)
    nq = number_of_quads(mesh)
    @assert all(mesh.active_vertex[1:nv])
    @assert count(mesh.active_vertex) == nv
    @assert all(mesh.active_quad[1:nq])
    @assert count(mesh.active_quad) == nq
end

function GameEnv(mesh, d0, max_actions)
    # _is_initial_mesh(mesh)
    @assert length(d0) == number_of_vertices(mesh)
    @assert max_actions > 0

    nvb = vertex_buffer(mesh)

    exp_d0 = zeros(Int, nvb)
    exp_d0[mesh.active_vertex] .= d0

    vertex_score = mesh.degree - exp_d0

    opt_score = abs(sum(vertex_score))
    current_score = sum(abs.(vertex_score))
    initial_score = current_score
    reward = 0
    num_actions = 0
    is_terminated = check_terminated(num_actions, max_actions, current_score, opt_score)

    return GameEnv(
        mesh,
        exp_d0,
        vertex_score,
        max_actions,
        num_actions,
        initial_score,
        current_score,
        opt_score,
        reward,
        is_terminated,
    )
end

function Base.show(io::IO, env::GameEnv)
    nv = number_of_vertices(env.mesh)
    nq = number_of_quads(env.mesh)
    cs = env.current_score
    os = env.opt_score
    remaining_actions = env.max_actions - env.num_actions
    term = env.is_terminated

    println(io, "GameEnv")
    println(io, "\t$nv vertices")
    println(io, "\t$nq quads")
    println(io, "\t$cs current score")
    if term
        println(io, "\tTERMINATED")
    else
        println(io, "\t$remaining_actions remaining actions")
    end
end

function active_vertex_scores(env)
    return env.vertex_score[env.mesh.active_vertex]
end

function update_env_after_action!(env)
    env.vertex_score = env.mesh.degree - env.desired_degree
    env.current_score = sum(abs.(env.vertex_score))
end

function step_left_flip!(env, quad, edge; maxdegree=7, no_action_reward=-4)
    success = false
    if is_valid_left_flip(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        @assert left_flip!(env.mesh, quad, edge, maxdegree)

        update_env_after_action!(env)
        env.reward = old_score - env.current_score
        success = true
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)

    return success
end

function step_right_flip!(env, quad, edge; maxdegree=7, no_action_reward=-4)
    success = false
    if is_valid_right_flip(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        @assert right_flip!(env.mesh, quad, edge, maxdegree)

        update_env_after_action!(env)
        env.reward = old_score - env.current_score
        success = true
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)

    return success
end

function synchronize_desired_degree_size!(env)
    vertex_buffer_size = vertex_buffer(env.mesh)
    if vertex_buffer_size > length(env.desired_degree)
        num_new_vertices = vertex_buffer_size - length(env.desired_degree)
        env.desired_degree = zero_pad_vector(env.desired_degree, num_new_vertices)
    end
end

function step_split!(env, quad, edge; maxdegree=7, no_action_reward=-4, new_vertex_desired_degree = 4)
    success = false

    if is_valid_split(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score

        new_vertex_idx = env.mesh.new_vertex_pointer

        @assert split!(env.mesh, quad, edge, maxdegree)
        synchronize_desired_degree_size!(env)

        # set the desired degree of the new vertex
        env.desired_degree[new_vertex_idx] = new_vertex_desired_degree

        update_env_after_action!(env)
        env.reward = old_score - env.current_score
        success = true
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)

    return success
end

function update_desired_degree_of_new_vertices!(env, vertex_ids, boundary_degree, interior_degree)
    for vid in vertex_ids
        if vertex_on_boundary(env.mesh, vid)
            env.desired_degree[vid] = boundary_degree
        else
            env.desired_degree[vid] = interior_degree
        end
    end
end

function step_global_split!(env, quad_idx, half_edge_idx; maxdegree = 7, no_action_reward = -4,
    new_boundary_vertex_desired_degree = 3, new_interior_vertex_desired_degree = 4)

    success = false
    if is_valid_global_split(env.mesh, quad_idx, half_edge_idx, maxdegree)
        old_score = env.current_score

        tracker = Tracker()
        @assert global_split!(env.mesh, quad_idx, half_edge_idx, tracker, maxdegree)
        synchronize_desired_degree_size!(env)

        update_desired_degree_of_new_vertices!(env, tracker.new_vertex_ids, new_boundary_vertex_desired_degree,
        new_interior_vertex_desired_degree)

        update_env_after_action!(env)
        env.reward = old_score - env.current_score
        success = true
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)

    return success
end

function step_collapse!(env, quad, edge; maxdegree = 7, no_action_reward=-4)
    success = false
    if is_valid_collapse(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        
        current_vertex = env.mesh.connectivity[edge, quad]
        collapsed_vertex = env.mesh.connectivity[next(next(edge)), quad]
        opp_ver_on_boundary = vertex_on_boundary(env.mesh, collapsed_vertex)
        
        @assert collapse!(env.mesh, quad, edge, maxdegree)
        
        # if collapsed vertex on boundary, set that as the desired degree of current vertex
        if opp_ver_on_boundary
            env.desired_degree[current_vertex] = env.desired_degree[collapsed_vertex]
        end
        # set the desired degree of collapsed vertex to zero
        env.desired_degree[collapsed_vertex] = 0

        update_env_after_action!(env)
        env.reward = old_score - env.current_score

        success = true
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)

    return success
end

function step_nothing!(env; reward = 0)
    env.num_actions += 1
    env.reward = reward
    env.is_terminated = check_terminated(env)

    return true
end

function make_edge_pairs(mesh)
    total_nq = quad_buffer(mesh)
    pairs = zeros(Int, 4total_nq)
    bdry_idx = 4total_nq + 1
    for quad = 1:total_nq
        for vertex = 1:4
            index = (quad - 1) * 4 + vertex
            opp_quad, opp_ver = mesh.q2q[vertex, quad], mesh.e2e[vertex, quad]
            pairs[index] = opp_quad == 0 ? bdry_idx : (opp_quad - 1) * 4 + opp_ver
        end
    end
    return pairs
end

function cycle_edges(x)
    nf, na = size(x)
    x = reshape(x, nf, 4, :)

    x1 = reshape(x, 4nf, 1, :)
    x2 = reshape(x[:, [2, 3, 4, 1], :], 4nf, 1, :)
    x3 = reshape(x[:, [3, 4, 1, 2], :], 4nf, 1, :)
    x4 = reshape(x[:, [4, 1, 2, 3], :], 4nf, 1, :)

    x = cat(x1, x2, x3, x4, dims=2)
    x = reshape(x, 4nf, :)

    return x
end

function make_level3_template(mesh)
    pairs = make_edge_pairs(mesh)
    x = reshape(mesh.connectivity, 1, :)

    cx = cycle_edges(x)

    pcx = zero_pad_matrix_cols(cx, 1)[:, pairs][3:end, :]
    cpcx = cycle_edges(pcx)

    pcpcx = zero_pad_matrix_cols(cpcx, 1)[:, pairs][3:end, :]
    cpcpcx = cycle_edges(pcpcx)

    template = vcat(cx, cpcx, cpcpcx)

    return template
end

function make_level4_template(mesh)
    pairs = make_edge_pairs(mesh)
    x = reshape(mesh.connectivity, 1, :)

    cx = cycle_edges(x)

    pcx = zero_pad_matrix_cols(cx, 1)[:, pairs][3:end, :]
    cpcx = cycle_edges(pcx)

    pcpcx = zero_pad_matrix_cols(cpcx, 1)[:, pairs][3:end, :]
    cpcpcx = cycle_edges(pcpcx)

    pcpcpcx = zero_pad_matrix_cols(cpcpcx, 1)[:, pairs][7:end, :]
    cpcpcpcx = cycle_edges(pcpcpcx)

    template = vcat(cx, cpcx, cpcpcx, cpcpcpcx)

    return template
end

function reindexed_desired_degree(old_desired_degree, new_vertex_indices, buffer_size)
    new_desired_degree = zeros(Int, buffer_size)
    for (old_idx, desired_degree) in enumerate(old_desired_degree)
        new_idx = new_vertex_indices[old_idx]
        if new_idx > 0
            new_desired_degree[new_idx] = desired_degree
        end
    end
    return new_desired_degree
end

function reindex_game_env!(env)
    reindex_quads!(env.mesh)
    new_vertex_indices = reindex_vertices!(env.mesh)
    vertex_buffer_size = vertex_buffer(env.mesh)
    env.desired_degree = reindexed_desired_degree(env.desired_degree, new_vertex_indices, vertex_buffer_size)
    env.vertex_score = env.mesh.degree - env.desired_degree
end

function active_vertex_desired_degree(env)
    return env.desired_degree[env.mesh.active_vertex]
end

function active_vertex_score(env)
    return env.vertex_score[env.mesh.active_vertex]
end