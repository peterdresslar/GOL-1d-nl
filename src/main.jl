# main.jl
using Statistics
include("life-1d.jl")
include("utils.jl")

# ───────────── argument handling (no defaults) ─────────────
function usage()
    println("1-D Game of Life\n")
    println("Usage: julia $PROGRAM_FILE <N> <r> <ρ₀> <steps> <persist_strategy> <stats_on>")
    println("  N      : integer > 0 (number of cells)")
    println("  r      : integer > 2 (neighbourhood radius parameter)")
    println("  ρ₀     : float 0.0–1.0 (initial live density)")
    println("  steps  : integer > 0 (simulation duration)")
    println("  persist_strategy : integer 0 or 1 or 2 (0 to not persist data, 1 to persist data as a grid of booleans, 2 to persist data as a list of lists of integers)")
    println("  stats_on : integer 0 or 1 (1 to print stats, 0 to not print stats)")
    exit(1)
end

function parse_args(args::Vector{String})
    if any(a -> a in ("-h", "--help"), args) || length(args) != 6
        usage()  # usage() always exits
    end

    try
        N     = parse(Int, args[1])
        r     = parse(Int, args[2])
        ρ₀    = parse(Float64, args[3]) 
        steps = parse(Int, args[4])
        persist_strategy = parse(Int, args[5])
        stats_on = parse(Int, args[6])

        # ---- validation ----
        if N ≤ 0; error("N must be > 0, got $N") end
        if r ≤ 2; error("r must be an integer > 2, got $r") end
        if !(0.0 ≤ ρ₀ ≤ 1.0); error("ρ₀ must be between 0.0 and 1.0, got $ρ₀") end
        if steps ≤ 0; error("steps must be > 0, got $steps") end
        if persist_strategy != 0 && persist_strategy != 1 && persist_strategy != 2; error("persist_strategy must be 0, 1, or 2, got $persist_strategy") end
        if stats_on != 0 && stats_on != 1; error("stats_on must be 0 or 1, got $stats_on") end

        return (N=N, r=r, ρ₀=ρ₀, steps=steps, persist_strategy=persist_strategy, stats_on=stats_on) # NamedTuple
    catch e
        println("\nError parsing arguments: ", sprint(showerror, e))
        usage()  # usage() always exits
    end
end 

# ───────────── main ─────────────

function main()
    args = parse_args(ARGS)

    init_reporting()
    # time the simulation
    t_start = time()

    offsets = get_offsets(args.r)

    board = init_1d_board_random(args.N, args.ρ₀)
    tmp = similar(board)          # scratch buffer

    # initialize the file depending on the persist strategy and return a handle for streaming(?)
    if args.persist_strategy == 1 || args.persist_strategy == 2
        handle = initialize_file(args.persist_strategy, args.N, args.r, args.ρ₀, args.steps)
    end

    for t in 1:args.steps
        step!(board, tmp, offsets)
        if args.stats_on == 1
            report_density_history(board, t)
        end
        if args.persist_strategy == 1 || args.persist_strategy == 2
            stream_board(handle, board, args.persist_strategy)
        end
    end
    println("Number of final live cells: $(sum(board))")
    t_end = time()
    println("Time taken: $(t_end - t_start) seconds")


end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end