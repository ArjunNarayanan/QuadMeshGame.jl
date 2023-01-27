function initialize_queue_with_boundary_edges(mesh)
    queue = Tuple{Int,Int}[]
    for quad in 1:quad_buffer(mesh)
        if is_active_quad(mesh, quad)
            for edge in 1:4
                if !has_neighbor(mesh, quad, edge)
                    push!(queue, (quad,edge))
                end
            end
        end
    end
    return queue
end

function initialize_distance_to_boundary(queue, mesh)
    distances = fill(-1, vertex_buffer(mesh))
    for (quad,edge) in queue 
        vidx = vertex(mesh, quad, edge)
        distances[vidx] = 0
    end
    return distances
end

function update_neighbor_distances!(quad, edge, distances, queue, mesh)
    vidx = vertex(mesh, quad, edge)
    new_distance = distances[vidx] + 1
    
    current_quad = quad
    current_edge = edge

    completed_spin = false
    is_boundary = false


    while !(completed_spin || is_boundary)
        current_edge = previous(current_edge)

        vidx = vertex(mesh, current_quad, current_edge)
        if distances[vidx] < 0
            distances[vidx] = new_distance
            push!(queue, (current_quad, current_edge))
        end

        q, e = neighbor(mesh, current_quad, current_edge), twin(mesh, current_quad, current_edge)
        current_quad = q
        current_edge = e

        completed_spin = current_quad == quad && current_edge == edge
        if current_quad == 0
            @assert current_edge == 0
            is_boundary = true
        end
    end
end

function compute_distance_to_boundary(mesh)
    queue = initialize_queue_with_boundary_edges(mesh)
    distances = initialize_distance_to_boundary(queue, mesh)

    while length(queue) > 0
        quad, edge = popfirst!(queue)
        update_neighbor_distances!(quad, edge, distances, queue, mesh)
    end
    
    return distances
end