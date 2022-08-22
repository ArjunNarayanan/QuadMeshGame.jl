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
