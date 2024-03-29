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

    q = neighbor(mesh, next_quad, next(next(next_half_edge)))
    h = twin(mesh, next_quad, next(next(next_half_edge)))

    if q == target_quad && h == target_half_edge
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

function mark_split_half_edges!(visited_quads, quad, edge, mesh)
    visited_quads[edge, quad] = true
    if has_neighbor(mesh, quad, edge)
        opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
        visited_quads[opp_edge, opp_quad] = true
    end
end

function check_finite_global_split_without_loops(mesh, quad, half_edge, maxsteps)
    numsteps = 0
    terminates = false
    visited_quads = falses(4, quad_buffer(mesh))

    # run forward path
    current_quad = quad 
    current_half_edge = half_edge
    mark_split_half_edges!(visited_quads, current_quad, current_half_edge, mesh)

    while numsteps < maxsteps && !terminates
        numsteps += 1

        if !has_neighbor(mesh, current_quad, next(current_half_edge))
            terminates = true
        elseif visited_quads[next(current_half_edge), current_quad]
            return false
        else
            mark_split_half_edges!(visited_quads, current_quad, 
                next(current_half_edge), mesh) 
            current_quad, current_half_edge = 
                step_forward_global_split_path(mesh, current_quad, current_half_edge)
        end
    end

    if !terminates 
        return false
    end

    # run reverse path
    current_quad = neighbor(mesh, quad, half_edge)
    current_half_edge = twin(mesh, quad, half_edge)
    numsteps = 0
    terminates = false
    while numsteps < maxsteps && !terminates
        numsteps += 1

        if !has_neighbor(mesh, current_quad, previous(current_half_edge))
            terminates = true
        elseif visited_quads[previous(current_half_edge), current_quad]
            return false
        else
            mark_split_half_edges!(visited_quads, current_quad, previous(current_half_edge), mesh) 
            current_quad, current_half_edge = step_reverse_global_split_path(mesh, current_quad, current_half_edge)
        end
    end

    return terminates
end

function check_finite_global_split(mesh, quad, half_edge, maxsteps)
    @assert has_neighbor(mesh, quad, half_edge)

    target_quad, target_half_edge = neighbor(mesh, quad, half_edge), twin(mesh, quad, half_edge)

    forward_terminates, loops = global_split_forward_path_terminates(mesh, quad, half_edge, target_quad, target_half_edge, maxsteps)
    if !forward_terminates
        return false
    end

    if loops
        return true
    end

    reverse_terminates, reverse_loops = global_split_reverse_path_terminates(mesh, target_quad, target_half_edge, quad, half_edge, maxsteps)
    @assert !reverse_loops

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

    v2 = vertex(mesh, quad_idx, next(half_edge_idx))
    if degree(mesh, v2) < 3
        return false
    end

    terminates = check_finite_global_split(mesh, quad_idx, half_edge_idx, maxsteps)
    if !terminates
        return false
    end

    return true
end

function is_valid_global_split_without_loops(mesh, quad_idx, half_edge_idx, maxsteps, maxdegree)
    if !is_active_quad(mesh, quad_idx) || !has_neighbor(mesh, quad_idx, half_edge_idx)
        return false
    end

    # degree of v1 increases by 1 so if it is at maxdegree, return false
    v1 = vertex(mesh, quad_idx, half_edge_idx)
    if degree(mesh, v1) >= maxdegree 
        return false
    end

    v2 = vertex(mesh, quad_idx, next(half_edge_idx))
    if degree(mesh, v2) < 3
        return false
    end

    terminates = check_finite_global_split_without_loops(mesh, quad_idx, half_edge_idx, maxsteps)
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

    set_vertex!(mesh, opp_quad, ol1, nv2)

    for (q, l, idx) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4), (1,2,3,4))
        set_neighbor_if_not_boundary!(mesh, q, l, new_quad_idx)
        set_twin_if_not_boundary!(mesh, q, l, idx)
    end

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

    set_neighbor!(mesh, nbr_quad, nl3, target_quad)
    set_twin!(mesh, nbr_quad, nl3, tl4)

end

function is_valid_path_split(mesh, quad_idx, half_edge_idx)

    @assert is_active_quad(mesh, quad_idx)
    
    next_half_edge = next(half_edge_idx)
    if !has_neighbor(mesh, quad_idx, next_half_edge)
        return false
    end

    v1 = vertex(mesh, quad_idx, next_half_edge)
    nq, nt = neighbor(mesh, quad_idx, next_half_edge), twin(mesh, quad_idx, next_half_edge)
    v2 = vertex(mesh, nq, next(nt))

    if v1 != v2
        return true
    end

    return false
end

function global_split_quads_along_path!(mesh, quad, half_edge, target_quad, target_half_edge, tracker, maxsteps)
    numsteps = 1
    terminated = false
    loops = false

    while !terminated && numsteps <= maxsteps
        if check_loop_in_next_step(mesh, quad, half_edge, target_quad, target_half_edge)
            close_loop_for_global_split!(mesh, quad, half_edge, target_quad, target_half_edge)
            terminated = true
            loops = true
        elseif is_valid_path_split(mesh, quad, half_edge)
            split_neighboring_quad_along_path!(mesh, quad, half_edge, tracker)
            quad, half_edge = step_forward_global_split_path(mesh, quad, half_edge)
        else
            @assert !has_neighbor(mesh, quad, next(half_edge))
            terminated = true
            loops = false
        end
        numsteps += 1
    end
    
    @assert terminated

    return loops
end

function global_split!(mesh, quad_idx, half_edge_idx, tracker, maxsteps, maxdegree = 7)
    @warn "This is experimental functionality"
    
    if !is_valid_global_split(mesh, quad_idx, half_edge_idx, maxsteps, maxdegree)
        return false
    end

    target_quad = neighbor(mesh, quad_idx, half_edge_idx)
    target_half_edge = twin(mesh, quad_idx, half_edge_idx)

    new_quad_idx = insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)

    loops = global_split_quads_along_path!(mesh, quad_idx, half_edge_idx, target_quad, target_half_edge, tracker, maxsteps)
    if !loops
        loops = global_split_quads_along_path!(mesh, new_quad_idx, 2, 0, 0, tracker, maxsteps)
        @assert !loops "Unexpected loop in second global split arm!"
    end

    return true
end

function global_split_quads_along_path_without_loops!(mesh, quad, half_edge, tracker, maxsteps)
    numsteps = 0
    terminated = false

    while !terminated && numsteps <= maxsteps
        numsteps += 1
        if is_valid_path_split(mesh, quad, half_edge)
            split_neighboring_quad_along_path!(mesh, quad, half_edge, tracker)
            quad, half_edge = step_forward_global_split_path(mesh, quad, half_edge)
        else
            @assert !has_neighbor(mesh, quad, next(half_edge))
            terminated = true
        end
    end
    @assert terminated
end

function global_split_without_loops!(mesh, quad_idx, half_edge_idx, tracker, maxsteps, maxdegree = 7)

    if !is_valid_global_split_without_loops(mesh, quad_idx, half_edge_idx, maxsteps, maxdegree)
        return false
    end

    new_quad_idx = insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)

    global_split_quads_along_path_without_loops!(mesh, quad_idx, half_edge_idx, tracker, 2*maxsteps)
    global_split_quads_along_path_without_loops!(mesh, new_quad_idx, 2, tracker, 2*maxsteps)
    
    return true
end