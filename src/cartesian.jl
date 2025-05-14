# cartesian.jl

# experimenting with the cartesian index in 1D and 2D
get_random_pattern(N::Int, ρ::Float64)::BitVector = rand(N) .< ρ

get_static_pattern()::BitVector = [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]

init_1d_board_pattern(pattern::BitVector)::BitVector = pattern

init_2d_board_pattern(pattern::BitVector, n::Int)::BitMatrix = transpose(reshape(pattern, n, n))

"""left to right, top to bottom"""

function verify()
    N = 25
    n = Int(sqrt(N))
    r = n
    ρ = 0.35    

    random_pattern = get_random_pattern(N, ρ)

    b1 = init_1d_board_pattern(random_pattern)
    b2 = init_2d_board_pattern(random_pattern, n)
    b3 = init_1d_board_pattern(get_static_pattern())
    b4 = init_2d_board_pattern(get_static_pattern(), n)

    # b1 and b2 should be visually "identical"
    println(b1)
    println(b2)

    # b3 and b4 should be visually "identical"
    println(b3)
    println(b4)


    # print cartesianindex for each element in b3. The values should be in the same order as b3.
    for i in CartesianIndices(b3)
        println(i, b3[i])  
    end

    # print cartesianindex for each element in b4. The values should be in the same order as b3.
    for i in CartesianIndices(b4)
        println(i, b4[i])  
    end
end





# ───────────── Index conversion helpers ─────────────
# 1-D index  ->  (row, col)  in row-major grid
function rowcol(i, n)
    return ((i-1) ÷ n + 1, (i-1) % n + 1)
end

# (row, col) ->  1-D index   in row-major grid
function flat(r, c, n)
    return (r-1)*n + c
end






