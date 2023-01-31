function all_active_vertices(mesh)
    conn = mesh.connectivity
    for v in conn
        if v == 0 || is_active_vertex(mesh, v)
            continue
        else
            return false
        end
    end
    return true
end

function no_quad_self_reference(mesh)
    for quad in 1:quad_buffer(mesh)
        if is_active_quad(mesh, quad)
            nbrs = mesh.q2q[:, quad]
            if any(quad .== nbrs)
                return false
            end
        end
    end
    return true
end

function all_active_quad_or_boundary(mesh)
    for quad in mesh.q2q
        if !(is_active_quad_or_boundary(mesh, quad))
            return false
        end
    end
    return true
end

function assert_valid_mesh(mesh)
    @assert all_active_vertices(mesh) "Found inactive vertices in mesh connectivity"
    @assert no_quad_self_reference(mesh) "Found self-referencing quads in mesh q2q"
    @assert all_active_quad_or_boundary(mesh) "Found inactive quads in mesh q2q"
end
