function is_valid_collapse(mesh, quad, edge, maxdegree)
    # check that current quad is active
    if !is_active_quad(mesh, quad)
        return false
    end

    # check that has neighbor at position 1 and 4
    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    if !(
        (has_neighbor(mesh, quad, l1) && has_neighbor(mesh, quad, l4)) ||
        (has_neighbor(mesh, quad, l2) && has_neighbor(mesh, quad, l3))
    )
        return false
    end

    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))
    if degree(mesh, v1) + degree(mesh, v3) - 2 >= maxdegree
        return false
    end

    return true
end
