struct Tracker
    new_vertex_ids
    on_boundary
    function Tracker()
        new_vertex_ids = Int[]
        on_boundary = Bool[]
        new(new_vertex_ids, on_boundary)
    end
end

function Base.show(io::IO, tracker::Tracker)
    num_new_verts = length(tracker.new_vertex_ids)
    @assert length(tracker.on_boundary) == num_new_verts
    println(io, "Tracker")
    println(io, "\t$num_new_verts vertices")
end

function update_tracker!(tracker, vertex_id, on_boundary)
    push!(tracker.new_vertex_ids, vertex_id)
    push!(tracker.on_boundary, on_boundary)
end

function step_forward_global_split_path(mesh, quad, half_edge)
    @assert has_neighbor(mesh, quad, next(half_edge))
    
    next_quad = neighbor(mesh, quad, next(half_edge))
    next_half_edge = next(twin(mesh, quad, next(half_edge)))
    return next_quad, next_half_edge
end

function step_reverse_global_split_path(mesh, quad, half_edge)
    @assert has_neighbor(mesh, quad, previous(half_edge))

    next_quad = neighbor(mesh, quad, previous(half_edge))
    next_half_edge = previous(twin(mesh, quad, previous(half_edge)))
    return next_quad, next_half_edge
end

function check_loop_in_next_step(mesh, quad, half_edge, target_quad, target_half_edge)
    next_quad = quad
    next_half_edge = half_edge

    for step in 1:2
        if !has_neighbor(mesh, next_quad, next(next_half_edge))
            return false
        end

        q = neighbor(mesh, next_quad, next(next_half_edge))
        h = next(twin(mesh, next_quad, next(next_half_edge)))

        next_quad = q
        next_half_edge = h
    end

    if next_quad == target_quad && next_half_edge == target_half_edge
        return true
    end

    return false
end

function global_split_forward_path_terminates(mesh, quad, half_edge, target_quad, target_half_edge, maxsteps)
    numsteps = 1
    terminates = false
    loops = false

    while numsteps <= maxsteps
        numsteps += 1

        if quad == target_quad && half_edge == target_half_edge
            terminates = true
            loops = true
            break
        end

        if !has_neighbor(mesh, quad, next(half_edge))
            terminates = true
            loops = false
            break
        end

        quad, half_edge = step_forward_global_split_path(mesh, quad, half_edge)
    end

    if loops 
        @assert terminates 
    end

    return terminates, loops
end

function global_split_reverse_path_terminates(mesh, quad, half_edge, target_quad, target_half_edge, maxsteps)
    numsteps = 1
    terminates = false
    loops = false

    while numsteps <= maxsteps
        numsteps += 1

        if quad == target_quad && half_edge == target_half_edge
            terminates = true
            loops = true
            break
        end

        if !has_neighbor(mesh, quad, previous(half_edge))
            terminates = true
            loops = false
            break
        end

        quad, half_edge = step_reverse_global_split_path(mesh, quad, half_edge)
    end

    if loops 
        @assert terminates 
    end

    return terminates, loops
end


function check_finite_global_split_length(mesh, quad, half_edge, maxsteps)
    @assert has_neighbor(mesh, quad, half_edge)

    target_quad, target_half_edge = neighbor(mesh, quad, half_edge), twin(mesh, quad, half_edge)

    forward_terminates, loops = global_split_forward_path_terminates(mesh, quad, half_edge, target_quad, target_half_edge, maxsteps)
    if !forward_terminates
        return false
    end

    if loops
        return true
    end

    reverse_terminates, _ = global_split_reverse_path_terminates(mesh, target_quad, target_half_edge, quad, half_edge, maxsteps)

    return reverse_terminates
end

function is_valid_global_split(mesh, quad_idx, half_edge_idx, maxsteps, maxdegree)
    if !is_active_quad(mesh, quad_idx) || !has_neighbor(mesh, quad_idx, half_edge_idx)
        return false
    end

    # degree of v1 increases by 1 so if it is at maxdegree, return false
    v1 = vertex(mesh, quad_idx, half_edge_idx)
    if degree(mesh, v1) >= maxdegree 
        return false
    end

    terminates = check_finite_global_split_length(mesh, quad_idx, half_edge_idx, maxsteps)
    if !terminates
        return false
    end

    return true
end

function insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)
    l1, l2, l3, l4 = next_cyclic_vertices(half_edge_idx)
    v1, v2, v3, v4 = (vertex(mesh, quad_idx, l) for l in (l1, l2, l3, l4))

    opp_quad, opp_half_edge = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    ol1, ol2, ol3, ol4 = next_cyclic_vertices(opp_half_edge)
    ov1, ov2, ov3, ov4 = (vertex(mesh, opp_quad, l) for l in (ol1, ol2, ol3, ol4))

    new_vertex_coords1 = new_vertex_coordinates(mesh, v2, v3)
    new_vertex_coords2 = new_vertex_coordinates(mesh, ov1, ov4)

    on_boundary1 = !has_neighbor(mesh, quad_idx, l2)
    on_boundary2 = !has_neighbor(mesh, opp_quad, ol4)

    deg1 = on_boundary1 ? 3 : 4
    deg2 = on_boundary2 ? 3 : 4

    nv1 = insert_vertex!(mesh, new_vertex_coords1, deg1, on_boundary1)
    nv2 = insert_vertex!(mesh, new_vertex_coords2, deg2, on_boundary2)

    update_tracker!(tracker, nv1, on_boundary1)
    update_tracker!(tracker, nv2, on_boundary2)

    nq1, nq2, nq3, nq4 = (quad_idx, opp_quad, neighbor(mesh, opp_quad, ol4), neighbor(mesh, quad_idx, l2))
    nl1, nl2, nl3, nl4 = (l1, ol1, twin(mesh, opp_quad, ol4), twin(mesh, quad_idx, l2))
    new_quad_idx = insert_quad!(mesh, (nv1, v1, nv2, v2), (nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))

    set_vertex!(mesh, quad_idx, l2, nv1)
    set_neighbor!(mesh, quad_idx, l1, new_quad_idx)
    set_twin!(mesh, quad_idx, l1, 1)

    set_vertex!(mesh, opp_quad, ol1, nv2)
    set_neighbor!(mesh, opp_quad, ol1, new_quad_idx)
    set_twin!(mesh, opp_quad, ol1, 2)

    increment_degree!(mesh, v1)
    decrement_degree!(mesh, v2)

    return new_quad_idx
end

function split_neighboring_quad_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    l2 = next(half_edge_idx)
    v2 = vertex(mesh, quad_idx, l2)

    @assert has_neighbor(mesh, quad_idx, l2)
    nbr_quad, nbr_twin = neighbor(mesh, quad_idx, l2), twin(mesh, quad_idx, l2)
    set_neighbor!(mesh, nbr_quad, nbr_twin, quad_idx)
    set_twin!(mesh, nbr_quad, nbr_twin, l2)

    ol1, ol2, ol3, ol4 = next_cyclic_vertices(nbr_twin)
    ov1, ov2, ov3, ov4 = (vertex(mesh, nbr_quad, l) for l in (ol1, ol2, ol3, ol4))

    new_vertex_coords = new_vertex_coordinates(mesh, ov3, ov4)
    on_boundary = !has_neighbor(mesh, nbr_quad, ol3)
    deg = on_boundary ? 3 : 4

    new_vertex_id = insert_vertex!(mesh, new_vertex_coords, deg, on_boundary)
    update_tracker!(tracker, new_vertex_id, on_boundary)

    set_vertex!(mesh, nbr_quad, ol2, v2)
    set_vertex!(mesh, nbr_quad, ol3, new_vertex_id)

    opp_quad, opp_twin = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    nq1, nq2, nq3, nq4 = (nbr_quad, opp_quad, neighbor(mesh, nbr_quad, ol2), neighbor(mesh, nbr_quad, ol3))
    nl1, nl2, nl3, nl4 = (ol2, previous(opp_twin), twin(mesh, nbr_quad, ol2), twin(mesh, nbr_quad, ol3))
    new_quad_idx = insert_quad!(mesh, (new_vertex_id, v2, ov2, ov3), (nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))

    for (q, l) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))
        set_neighbor_if_not_boundary!(mesh, q, l, new_quad_idx)
    end
    
    for (q, l, idx) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4), (1, 2, 3, 4))
        set_twin_if_not_boundary!(mesh, q, l, idx)
    end

end

function close_loop_for_global_split!(mesh, quad_idx, half_edge_idx, target_quad, target_half_edge)
    @assert check_loop_in_next_step(mesh, quad_idx, half_edge_idx, target_quad, target_half_edge)
    
    l1, l2, l3, l4 = next_cyclic_vertices(half_edge_idx)
    v1, v2, v3, v4 = (vertex(mesh, quad_idx, l) for l in (l1, l2, l3, l4))

    @assert has_neighbor(mesh, quad_idx, l2)
    nbr_quad, nbr_twin = neighbor(mesh, quad_idx, l2), twin(mesh, quad_idx, l2)
    set_neighbor!(mesh, nbr_quad, nbr_twin, quad_idx)
    set_twin!(mesh, nbr_quad, nbr_twin, l2)

    nl1, nl2, nl3, nl4 = next_cyclic_vertices(nbr_twin)
    nv1, nv2, nv3, nv4 = (vertex(mesh, nbr_quad, l) for l in (nl1, nl2, nl3, nl4))

    tl1, tl2, tl3, tl4 = next_cyclic_vertices(target_half_edge)
    tv1, tv2, tv3, tv4 = (vertex(mesh, target_quad, l) for l in (tl1, tl2, tl3, tl4))
    
    opp_quad, opp_twin = neighbor(mesh, quad_idx, l1), twin(mesh, quad_idx, l1)
    ol1, ol2, ol3, ol4 = next_cyclic_vertices(opp_twin)
    ov1, ov2, ov3, ov4 = (vertex(mesh, opp_quad, l) for l in (ol1, ol2, ol3, ol4))

    opp_target_quad, opp_target_twin = neighbor(mesh, target_quad, target_half_edge), 
                                        twin(mesh, target_quad, target_half_edge)

    newv1, newv2, newv3, newv4 = tv1, v2, ov4, nv3
    newq1, newq2, newq3, newq4 = nbr_quad, opp_quad, neighbor(mesh, nbr_quad, nl2), neighbor(mesh, target_quad, tl1)
    newl1, newl2, newl3, newl4 = nl2, ol4, twin(mesh, nbr_quad, nl2), next(twin(mesh, target_quad, tl1))
    new_quad_idx = insert_quad!(mesh, (newv1, newv2, newv3, newv4), 
                                      (newq1, newq2, newq3, newq4), 
                                      (newl1, newl2, newl3, newl4))

    set_vertex!(mesh, nbr_quad, nl2, v2)
    set_vertex!(mesh, nbr_quad, nl3, tv1)

    for (q, l) in zip((newq1, newq2, newq3, newq4), (newl1, newl2, newl3, newl4))
        set_neighbor_if_not_boundary!(mesh, q, l, new_quad_idx)
    end

    for (q, l, idx) in zip((newq1, newq2, newq3, newq4), (newl1, newl2, newl3, newl4), (1, 2, 3, 4))
        set_twin_if_not_boundary!(mesh, q, l, idx)
    end

end

function is_valid_path_split(mesh, quad_idx, half_edge_idx)
    @assert is_active_quad(mesh, quad_idx)
    if !has_neighbor(mesh, quad_idx, next(half_edge_idx))
        return false
    end

    oq, ot = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    nq, nt = neighbor(mesh, quad_idx, next(half_edge_idx)), twin(mesh, quad_idx, next(half_edge_idx))
    noq, not = neighbor(mesh, oq, previous(ot)), twin(mesh, oq, previous(ot))

    if noq == nq && not == nt
        onq, ont = neighbor(mesh, nq, nt), twin(mesh, nq, nt)
        @assert (onq == quad_idx && ont == next(half_edge_idx)) || (onq == oq && ont == previous(ot))

        return true
    else
        return false
    end

end

function global_split_quads_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    while is_valid_path_split(mesh, quad_idx, half_edge_idx)
        split_neighboring_quad_along_path!(mesh, quad_idx, half_edge_idx, tracker)
        prev_quad = quad_idx
        prev_edge = half_edge_idx

        quad_idx = neighbor(mesh, prev_quad, next(prev_edge))
        half_edge_idx = next(twin(mesh, prev_quad, next(prev_edge)))
    end
end


#=
TO DO - NEED TO FIX THE CASE WHERE THE NODE BEING SPLIT IS DEGREE 3!
=#
function global_split!(mesh, quad_idx, half_edge_idx, tracker, maxsteps, maxdegree = 7)
    @warn "This is experimental, don't trust your results"
    
    if !is_valid_global_split(mesh, quad_idx, half_edge_idx, maxsteps, maxdegree)
        return false
    end

    new_quad_idx = insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)

    global_split_quads_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    global_split_quads_along_path!(mesh, new_quad_idx, 2, tracker)

    return true
end