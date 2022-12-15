function next(i)
    @assert i == 1 || i == 2 || i == 3 || i == 4
    if i == 4
        return 1
    else
        return i + 1
    end
end

function previous(i)
    @assert i == 1 || i == 2 || i == 3 || i == 4
    if i == 1
        return 4
    else
        return i - 1
    end
end

function find_point_index(point_set, point)
    return argmin(vec(sum((point_set .- point).^2, dims=1)))
end

function enclosed_angle(v1,v2)
    @assert length(v1) == length(v2) == 2
    dotp = v1' * v2
    detp = v1[1]*v2[2] - v1[2]*v2[1]
    rad = atan(detp, dotp)
    if rad < 0
        rad += 2pi
    end

    return rad2deg(rad) 
end

function polygon_interior_angles(p)
    n = size(p,2)
    angles = zeros(n)
    for i = 1:n
        previ = i == 1 ? n : i -1
        nexti = i == n ? 1 : i + 1

        v1 = p[:,nexti] - p[:,i]
        v2 = p[:,previ] - p[:,i]
        angles[i] = enclosed_angle(v1,v2)
    end
    return angles
end

function desired_degree(angle; target_angle = 90)
    n = 2
    while abs(target_angle - angle/n) < abs(target_angle - angle/(n-1))
        n += 1
    end
    return n
end

function pad_vector(vec, num_new_entries, value)
    return [vec; fill(value, num_new_entries)]
end

function zero_pad_vector(vec, num_new_entries)
    T = eltype(vec)
    return pad_vector(vec, num_new_entries, zero(T))
end

function pad_matrix_cols(mat, num_new_cols, value)
    nr, _ = size(mat)
    return [mat fill(value, (nr, num_new_cols))]
end

function zero_pad_matrix_cols(m, num_new_cols)
    T = eltype(m)
    return pad_matrix_cols(m, num_new_cols, zero(T))
end
