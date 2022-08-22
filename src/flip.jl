function is_valid_left_flip(mesh::QuadMesh, quad, edge; maxdegree = 7)
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end
    v1, v2, v3, v4 = next_cyclic_vertices(edge)
    if degree(mesh, vertex(mesh, v1)) < 4 || degree(mesh, vertex(mesh, v2)) < 4
        return false
    end
    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
end
