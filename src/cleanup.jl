function is_valid_cleanup_source_half_edge(mesh, quad, half_edge)
    if !has_neighbor(mesh, quad, half_edge)
        return false
    end

    vidx = vertex(mesh, quad, half_edge)
    flag = vertex_on_boundary(mesh, vidx) && !is_geometric_vertex(mesh, vidx) && degree(mesh, vidx) == 3
    return flag
end

function mark_cleanup_path_visited!(mesh, quad, half_edge, visited)
    @assert !visited[half_edge, quad]
    visited[half_edge, quad] = true
    
    nbr_quad, nbr_half_edge = neighbor(mesh, quad, half_edge), twin(mesh, quad, half_edge)
    if nbr_quad != 0
        @assert !visited[nbr_half_edge, nbr_quad]
        visited[nbr_half_edge, nbr_quad] = true
    end
end

function is_valid_cleanup(mesh, src_quad, src_half_edge, maxsteps)
    @assert maxsteps > 0

    if !is_valid_cleanup_source_half_edge(mesh, src_quad, src_half_edge)
        return false
    end

    counter = 0
    dst_quad = src_quad
    dst_half_edge = src_half_edge
    next_dst_half_edge = next(dst_half_edge)

    while has_neighbor(mesh, dst_quad, next_dst_half_edge) && counter <= maxsteps
        counter += 1
        if !has_neighbor(mesh, dst_quad, dst_half_edge)
            return false
        end

        _dst_quad = neighbor(mesh, dst_quad, next_dst_half_edge)
        _dst_half_edge = twin(mesh, dst_quad, next_dst_half_edge)
        
        dst_quad = _dst_quad
        dst_half_edge = next(_dst_half_edge)

        vidx = vertex(mesh, dst_quad, dst_half_edge)
        if degree(mesh, vidx) != 4 || is_geometric_vertex(mesh, vidx)
            return false
        end
        next_dst_half_edge = next(dst_half_edge)
    end

    if counter > maxsteps
        return false
    end

    if !has_neighbor(mesh, dst_quad, dst_half_edge)
        return false
    end

    nbr_quad, nbr_half_edge = neighbor(mesh, dst_quad, dst_half_edge), twin(mesh, dst_quad, dst_half_edge)
    if !is_valid_cleanup_source_half_edge(mesh, nbr_quad, nbr_half_edge)
        return false
    end

    return true
end

function _step_cleanup_merge!(mesh, quad, half_edge)
    @assert has_neighbor(mesh, quad, half_edge)
    nbr_quad, nbr_half_edge = neighbor(mesh, quad, half_edge), twin(mesh, quad, half_edge)
    @assert quad > nbr_quad

    l1, l2, l3, l4 = next_cyclic_vertices(half_edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, l) for l in (l1, l2, l3, l4))

    l5, l6, l7, l8 = next_cyclic_vertices(nbr_half_edge)
    v5, v6, v7, v8 = (vertex(mesh, nbr_quad, l) for l in (l5, l6, l7, l8))

    set_vertex!(mesh, quad, l1, v7)
    set_vertex!(mesh, quad, l2, v8)
    
    nq1, nq2, nq3, nq4 = (neighbor(mesh, quad, l) for l in (l1, l2, l3, l4))
    nl1, nl2, nl3, nl4 = (twin(mesh, quad, l) for l in (l1, l2, l3, l4))

    nq5, nq6, nq7, nq8 = (neighbor(mesh, nbr_quad, l) for l in (l5, l6, l7, l8))
    nl5, nl6, nl7, nl8 = (twin(mesh, nbr_quad, l) for l in (l5, l6, l7, l8))

    set_neighbor!(mesh, quad, l1, nq7)
    set_twin!(mesh, quad, l1, nl7)

    set_neighbor_if_not_boundary!(mesh, nq6, nl6, quad)
    set_twin_if_not_boundary!(mesh, nq6, nl6, l4)

    set_neighbor_if_not_boundary!(mesh, nq7, nl7, quad)
    set_twin_if_not_boundary!(mesh, nq7, nl7, l1)

    set_neighbor_if_not_boundary!(mesh, nq8, nl8, quad)
    set_twin_if_not_boundary!(mesh, nq8, nl8, l2)

    delete_quad!(mesh, nbr_quad)

    return true
end

function step_cleanup_merge!(mesh, quad, half_edge)
    @assert has_neighbor(mesh, quad, half_edge)
    vertex_to_delete = vertex(mesh, quad, half_edge)

    nbr_quad, nbr_half_edge = neighbor(mesh, quad, half_edge), twin(mesh, quad, half_edge)
    if quad > nbr_quad
        _step_cleanup_merge!(mesh, quad, half_edge)
    else
        _step_cleanup_merge!(mesh, nbr_quad, nbr_half_edge)
    end

    delete_vertex!(mesh, vertex_to_delete)
    
    return true 
end

function cleanup_path!(mesh, quad, half_edge, maxsteps)
    if !is_valid_cleanup(mesh, quad, half_edge, maxsteps)
        return false
    end

    numsteps = 0
    next_half_edge = next(half_edge)
    final_vertex_to_delete = 0
    
    while has_neighbor(mesh, quad, next_half_edge) && numsteps <= maxsteps
        numsteps += 1

        nbr_quad = neighbor(mesh, quad, next_half_edge)
        nbr_half_edge = next(twin(mesh, quad, next_half_edge))

        step_cleanup_merge!(mesh, quad, half_edge)

        quad = nbr_quad
        half_edge = nbr_half_edge
        next_half_edge = next(half_edge)
    end
    @assert numsteps <= maxsteps

    nbr_quad = neighbor(mesh, quad, half_edge)
    nbr_half_edge = twin(mesh, quad, half_edge)
    vertex_to_delete = vertex(mesh, nbr_quad, nbr_half_edge)
    
    step_cleanup_merge!(mesh, quad, half_edge)
    delete_vertex!(mesh, vertex_to_delete)

    return true
end

function cleanup!(mesh, maxsteps)
    quad_buffer_size = quad_buffer(mesh)
    for quad_idx in 1:quad_buffer_size
        for half_edge_idx in 1:4
            if is_active_quad(mesh, quad_idx) && is_valid_cleanup(mesh, quad_idx, half_edge_idx, maxsteps)
                @assert cleanup_path!(mesh, quad_idx, half_edge_idx, maxsteps)
            end
        end
    end
end