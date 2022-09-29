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