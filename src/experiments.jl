# experiments.jl

# run a few life-2d simulations with different loading patterns

include("life-2d.jl")
include("cartesian.jl")

# ───────────── 1D ─────────────

N = 25
n = Int(sqrt(N))
torus = true


function main()
    pattern = get_static_pattern()
    board = init_2d_board_pattern(pattern, n)
    tmp = similar(board)
    offsets = get_offsets_2d(n)

    println(board)

    for step in 1:10
        step_2d!(board, tmp, offsets, torus)
        # print the board in 2d
        for i in 1:n
            for j in 1:n
                print(board[i, j] ? "■" : "□")
            end
            println()
        end
    end
end




if abspath(PROGRAM_FILE) == @__FILE__
    main()
end