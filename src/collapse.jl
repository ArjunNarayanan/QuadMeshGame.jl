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
    # check degree of merging vertices
    if degree(mesh, v1) + degree(mesh, v3) - 2 >= maxdegree
        return false
    end

    # check that at least one of the merging vertices is interior
    if vertex_on_boundary(mesh, v1) && vertex_on_boundary(mesh, v3)
        return false
    end

    return true
end

function collapsed_vertex_coordinates(mesh, v1, v2)
    if vertex_on_boundary(mesh, v1)
        return vertex_coordinates(mesh, v1)
    elseif vertex_on_boundary(mesh, v2)
        return vertex_coordinates(mesh, v2)
    else
        return new_vertex_coordinates(mesh, v1, v2)
    end
end

function collapse!(mesh, quad, edge, maxdegree = 7)
    if !is_valid_collapse(mesh, quad, edge, maxdegree)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    # move the collapsed vertex to the mean of v1 and v3
    new_coords = collapsed_vertex_coordinates(mesh, v1, v2)
    set_coordinates!(mesh, v1, new_coords)

    # set degree of v1 
    dv1 = degree(mesh, v1) + degree(mesh, v3) - 2
    set_degree!(mesh, v1, dv1)

    # change connectivity of neighbors if not boundary 
    ol1, ol2, ol3, ol4 = (twin(mesh, quad, i) for i in (l1, l2, l3, l4))
    q1, q2, q3, q4 = (neighbor(mesh, quad, i) for i in (l1, l2, l3, l4))
    set_vertex_if_not_boundary!(mesh, q2, ol2, v1)
    set_vertex_if_not_boundary!(mesh, q3, next(ol3), v1)

    # change q2q of neighbors if not boundary
    for (q, ol, nq) in zip((q1, q2, q3, q4), (ol1, ol2, ol3, ol4), (q2, q1, q4, q3))
        set_neighbor_if_not_boundary!(mesh, q, ol, nq)
    end

    # change e2e of neighbors if not boundary
    for (q, ol, nol) in zip((q1, q2, q3, q4), (ol1, ol2, ol3, ol4), (ol2, ol1, ol4, ol3))
        set_twin_if_not_boundary!(mesh, q, ol, nol)
    end

    # decrement degree of v2, v4 
    decrement_degree!(mesh, v2)
    decrement_degree!(mesh, v4)

    # delete v3
    delete_vertex!(mesh, v3)
    # delete quad
    delete_quad!(mesh, quad)

    return true
end
